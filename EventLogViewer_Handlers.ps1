# Enhanced Event Log Viewer v2.0


function Initialize-EventHandlers {
    <#
    .SYNOPSIS
        Attaches all event handlers to UI controls
    #>
    
    # Category selection changes - all 14 categories
    $script:controls.rbAccountActivity.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbADAccountChanges.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbSecurityThreat.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbServerHealth.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbApplicationIssues.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbSysmon.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbPowerShell.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbDefender.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbFirewall.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbTaskScheduler.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbRemoteDesktop.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbCodeIntegrity.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbWMI.Add_Checked({ Update-EventIDComboBox })
    $script:controls.rbBitLocker.Add_Checked({ Update-EventIDComboBox })
    
    # Source selection changed
    $script:controls.cbSource.Add_SelectionChanged({
        if ($script:controls.cbSource.SelectedIndex -eq 0) {
            $script:controls.txtComputer.IsEnabled = $true
            $script:controls.chkAutoRefresh.IsEnabled = $true
        } else {
            $script:controls.txtComputer.IsEnabled = $false
            $script:controls.chkAutoRefresh.IsEnabled = $false
            $script:controls.chkAutoRefresh.IsChecked = $false
        }
    })
    
    # Search button
    $script:controls.btnSearch.Add_Click({
        $isImportedSource = ($script:controls.cbSource.SelectedIndex -eq 1)
        
        if ($isImportedSource) {
            if ($script:importedEVTXFiles.Count -eq 0) {
                [System.Windows.MessageBox]::Show(
                    "No EVTX files imported. Click 'Import EVTX' to add files.", 
                    "No Files", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Information
                )
                return
            }
            Invoke-ImportedFileSearch
        } else {
            Invoke-LiveMachineSearch
        }
    })
    
    # Stop Search button - simple cancel flag
    $script:controls.btnStopSearch.Add_Click({
        $script:searchCancelled = $true
        $script:controls.lblStatus.Content = "Cancelling..."
    })
    
    # Clear button
    $script:controls.btnClear.Add_Click({
        $script:allEvents.Clear()
        $script:currentPage = 1
        $script:controls.dgResults.ItemsSource = $null
        $script:controls.lblStatus.Content = ""
        $script:controls.txtStatusBar.Text = "Ready"
        Update-PaginationDisplay
    })
    
    # Import EVTX button - INSTANT file adding + auto date range
    $script:controls.btnImportEVTX.Add_Click({
        $openDialog = New-Object System.Windows.Forms.OpenFileDialog
        $openDialog.Filter = "Event Log files (*.evtx)|*.evtx"
        $openDialog.Title = "Select EVTX File(s) to Import"
        $openDialog.Multiselect = $true
        
        if ($openDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $newFiles = 0
            $minDate = $null
            $maxDate = $null
            
            # Just add files to the list - NO validation
            foreach ($file in $openDialog.FileNames) {
                if ($script:importedEVTXFiles -notcontains $file) {
                    $null = $script:importedEVTXFiles.Add($file)
                    $newFiles++
                    
                    # Quick peek at first and last event to get date range
                    try {
                        $firstEvent = Get-WinEvent -Path $file -MaxEvents 1 -Oldest -ErrorAction SilentlyContinue
                        $lastEvent = Get-WinEvent -Path $file -MaxEvents 1 -ErrorAction SilentlyContinue
                        
                        if ($firstEvent -and ($null -eq $minDate -or $firstEvent.TimeCreated -lt $minDate)) {
                            $minDate = $firstEvent.TimeCreated
                        }
                        if ($lastEvent -and ($null -eq $maxDate -or $lastEvent.TimeCreated -gt $maxDate)) {
                            $maxDate = $lastEvent.TimeCreated
                        }
                    } catch {
                        # Ignore errors
                    }
                }
            }
            
            if ($newFiles -gt 0) {
                Update-ImportedFilesDisplay
                $script:controls.cbSource.SelectedIndex = 1
                
                # Auto-adjust date range if we found dates
                if ($minDate -and $maxDate) {
                    $script:controls.dpStart.SelectedDate = $minDate.Date
                    $script:controls.dpEnd.SelectedDate = $maxDate.Date
                    
                    [System.Windows.MessageBox]::Show(
                        "Added $newFiles file(s)!`n`nDate range auto-adjusted:`nStart: $($minDate.ToString('yyyy-MM-dd'))`nEnd: $($maxDate.ToString('yyyy-MM-dd'))`n`nClick Search to load all events.", 
                        "Files Added", 
                        [System.Windows.MessageBoxButton]::OK, 
                        [System.Windows.MessageBoxImage]::Information
                    )
                } else {
                    [System.Windows.MessageBox]::Show(
                        "Added $newFiles file(s)!`n`nSelect a category and click Search to analyze.", 
                        "Files Added", 
                        [System.Windows.MessageBoxButton]::OK, 
                        [System.Windows.MessageBoxImage]::Information
                    )
                }
            } else {
                [System.Windows.MessageBox]::Show(
                    "All selected files were already imported.", 
                    "No New Files", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Information
                )
            }
        }
    })
    
    # Manage Files button
    $script:controls.btnManageFiles.Add_Click({
        if ($script:importedEVTXFiles.Count -eq 0) {
            [System.Windows.MessageBox]::Show(
                "No imported files to manage.", 
                "No Files", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Information
            )
            return
        }
        
        [xml]$manageXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Manage Imported Files" Height="450" Width="700" WindowStartupLocation="CenterOwner">
    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <TextBlock Grid.Row="0" Text="Imported EVTX Files:" FontWeight="Bold" Margin="0,0,0,10"/>
        
        <ListBox x:Name="lstFiles" Grid.Row="1" Margin="0,0,0,10" SelectionMode="Extended"/>
        
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
            <Button x:Name="btnRemove" Content="Remove Selected" Width="120" Height="30" Margin="5,0"/>
            <Button x:Name="btnRemoveAll" Content="Remove All" Width="100" Height="30" Margin="5,0"/>
            <Button x:Name="btnClose" Content="Close" Width="80" Height="30" Margin="5,0"/>
        </StackPanel>
    </Grid>
</Window>
"@
        
        $manageReader = New-Object System.Xml.XmlNodeReader $manageXaml
        $manageWindow = [Windows.Markup.XamlReader]::Load($manageReader)
        $manageWindow.Owner = $script:window
        
        $lstFiles = $manageWindow.FindName("lstFiles")
        $btnRemove = $manageWindow.FindName("btnRemove")
        $btnRemoveAll = $manageWindow.FindName("btnRemoveAll")
        $btnClose = $manageWindow.FindName("btnClose")
        
        foreach ($file in $script:importedEVTXFiles) {
            $null = $lstFiles.Items.Add($file)
        }
        
        $btnRemove.Add_Click({
            if ($lstFiles.SelectedItems.Count -eq 0) {
                [System.Windows.MessageBox]::Show(
                    "Please select file(s) to remove.", 
                    "No Selection", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Information
                )
                return
            }
            
            $result = [System.Windows.MessageBox]::Show(
                "Remove $($lstFiles.SelectedItems.Count) selected file(s)?", 
                "Confirm Removal", 
                [System.Windows.MessageBoxButton]::YesNo, 
                [System.Windows.MessageBoxImage]::Question
            )
            
            if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
                $toRemove = @($lstFiles.SelectedItems)
                foreach ($item in $toRemove) {
                    $script:importedEVTXFiles.Remove($item)
                    $lstFiles.Items.Remove($item)
                }
                Update-ImportedFilesDisplay
            }
        })
        
        $btnRemoveAll.Add_Click({
            $result = [System.Windows.MessageBox]::Show(
                "Remove ALL $($script:importedEVTXFiles.Count) imported file(s)?", 
                "Confirm Removal", 
                [System.Windows.MessageBoxButton]::YesNo, 
                [System.Windows.MessageBoxImage]::Warning
            )
            
            if ($result -eq [System.Windows.MessageBoxResult]::Yes) {
                $script:importedEVTXFiles.Clear()
                $lstFiles.Items.Clear()
                Update-ImportedFilesDisplay
                $manageWindow.Close()
            }
        })
        
        $btnClose.Add_Click({
            $manageWindow.Close()
        })
        
        $null = $manageWindow.ShowDialog()
    })
    
    # Export CSV button
    $script:controls.btnExportCSV.Add_Click({
        if ($script:allEvents.Count -eq 0) {
            [System.Windows.MessageBox]::Show(
                "No data to export. Please run a search first.", 
                "No Data", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Warning
            )
            return
        }
        
        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = "CSV files (*.csv)|*.csv"
        $saveDialog.FileName = "EventLog_Export_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
        
        if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $script:allEvents | 
                    Select-Object TimeCreated, LogName, Source, Id, Meaning, LevelDisplayName, Message | 
                    Export-Csv -Path $saveDialog.FileName -NoTypeInformation -ErrorAction Stop
                
                [System.Windows.MessageBox]::Show(
                    "Successfully exported $($script:allEvents.Count) events to:`n`n$($saveDialog.FileName)", 
                    "Export Complete", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Information
                )
            } catch {
                [System.Windows.MessageBox]::Show(
                    "Error exporting data:`n`n$($_.Exception.Message)", 
                    "Export Error", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Error
                )
            }
        }
    })
    
    # Export Excel button
    $script:controls.btnExportExcel.Add_Click({
        if ($script:allEvents.Count -eq 0) {
            [System.Windows.MessageBox]::Show(
                "No data to export. Please run a search first.", 
                "No Data", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Warning
            )
            return
        }
        
        $saveDialog = New-Object System.Windows.Forms.SaveFileDialog
        $saveDialog.Filter = "Excel files (*.xlsx)|*.xlsx"
        $saveDialog.FileName = "EventLog_Export_$(Get-Date -Format 'yyyyMMdd_HHmmss').xlsx"
        
        if ($saveDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            try {
                $excel = New-Object -ComObject Excel.Application
                $excel.Visible = $false
                $excel.DisplayAlerts = $false
                $workbook = $excel.Workbooks.Add()
                $worksheet = $workbook.Worksheets.Item(1)
                
                # Headers
                $headers = @("Time Created", "Log Name", "Source", "Event ID", "Meaning", "Level", "Message")
                for ($i = 0; $i -lt $headers.Count; $i++) {
                    $worksheet.Cells.Item(1, $i + 1) = $headers[$i]
                }
                
                $headerRange = $worksheet.Range("A1", [char](64 + $headers.Count) + "1")
                $headerRange.Font.Bold = $true
                $headerRange.Interior.ColorIndex = 15
                
                # Data
                $row = 2
                foreach ($evt in $script:allEvents) {
                    $worksheet.Cells.Item($row, 1) = $evt.TimeCreated.ToString()
                    $worksheet.Cells.Item($row, 2) = $evt.LogName
                    $worksheet.Cells.Item($row, 3) = $evt.Source
                    $worksheet.Cells.Item($row, 4) = $evt.Id
                    $worksheet.Cells.Item($row, 5) = $evt.Meaning
                    $worksheet.Cells.Item($row, 6) = $evt.LevelDisplayName
                    $worksheet.Cells.Item($row, 7) = $evt.Message
                    $row++
                }
                
                $worksheet.UsedRange.Columns.AutoFit() | Out-Null
                $workbook.SaveAs($saveDialog.FileName)
                $workbook.Close()
                $excel.Quit()
                
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($worksheet) | Out-Null
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($workbook) | Out-Null
                [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
                
                [System.Windows.MessageBox]::Show(
                    "Successfully exported $($script:allEvents.Count) events to:`n`n$($saveDialog.FileName)", 
                    "Export Complete", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Information
                )
            } catch {
                [System.Windows.MessageBox]::Show(
                    "Error exporting to Excel:`n`n$($_.Exception.Message)`n`nMake sure Excel is installed.", 
                    "Export Error", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Error
                )
            }
        }
    })
    
    # Web Search button
    $script:controls.btnWebSearch.Add_Click({
        $selectedEvent = $script:controls.dgResults.SelectedItem
        if ($null -eq $selectedEvent) {
            [System.Windows.MessageBox]::Show(
                "Please select an event to search for.", 
                "No Selection", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Information
            )
            return
        }
        
        $eventId = $selectedEvent.Id
        $source = $selectedEvent.Source
        $searchQuery = "Event ID $eventId $source Windows"
        $encodedQuery = [System.Uri]::EscapeDataString($searchQuery)
        
        try {
            Start-Process "https://duckduckgo.com/?q=$encodedQuery"
        } catch {
            [System.Windows.MessageBox]::Show(
                "Error opening browser: $($_.Exception.Message)", 
                "Error", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Error
            )
        }
    })
    
    # Auto-refresh checkbox
    $script:controls.chkAutoRefresh.Add_Checked({
        $script:autoRefreshTimer = New-Object System.Windows.Threading.DispatcherTimer
        $script:autoRefreshTimer.Interval = [TimeSpan]::FromSeconds(30)
        $script:autoRefreshTimer.Add_Tick({
            if ($script:controls.cbSource.SelectedIndex -eq 0) {
                Invoke-LiveMachineSearch
            }
        })
        $script:autoRefreshTimer.Start()
        $script:controls.lblStatus.Content = "Auto-refresh enabled (30s)"
    })
    
    $script:controls.chkAutoRefresh.Add_Unchecked({
        if ($script:autoRefreshTimer) {
            $script:autoRefreshTimer.Stop()
            $script:autoRefreshTimer = $null
            $script:controls.lblStatus.Content = "Auto-refresh disabled"
        }
    })
    
    # Pagination buttons
    $script:controls.btnFirstPage.Add_Click({
        $script:currentPage = 1
        Update-PaginationDisplay
    })
    
    $script:controls.btnPrevPage.Add_Click({
        if ($script:currentPage -gt 1) {
            $script:currentPage--
            Update-PaginationDisplay
        }
    })
    
    $script:controls.btnNextPage.Add_Click({
        $totalPages = [Math]::Ceiling($script:allEvents.Count / $script:pageSize)
        if ($script:currentPage -lt $totalPages) {
            $script:currentPage++
            Update-PaginationDisplay
        }
    })
    
    $script:controls.btnLastPage.Add_Click({
        $totalPages = [Math]::Ceiling($script:allEvents.Count / $script:pageSize)
        $script:currentPage = $totalPages
        Update-PaginationDisplay
    })
    
    # Page size changed
    $script:controls.cbPageSize.Add_SelectionChanged({
        $script:pageSize = [int]$script:controls.cbPageSize.SelectedItem.Content
        $script:currentPage = 1
        Update-PaginationDisplay
    })
    
    # Double-click to view event details
    $script:controls.dgResults.Add_MouseDoubleClick({
        $selectedEvent = $script:controls.dgResults.SelectedItem
        if ($selectedEvent) {
            $details = @"
Event Details
═════════════════════════════════════════════════════

Time Created:    $($selectedEvent.TimeCreated)
Log Name:        $($selectedEvent.LogName)
Source:          $($selectedEvent.Source)
Event ID:        $($selectedEvent.Id)
Meaning:         $($selectedEvent.Meaning)
Level:           $($selectedEvent.LevelDisplayName)

Message:
═════════════════════════════════════════════════════

$($selectedEvent.Message)
"@
            
            [System.Windows.MessageBox]::Show(
                $details, 
                "Event Details - ID $($selectedEvent.Id)", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Information
            )
        }
    })
}