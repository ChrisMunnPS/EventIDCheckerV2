function Update-ImportedFilesDisplay {
    $count = $script:importedEVTXFiles.Count
    
    if ($count -eq 0) {
        $script:controls.lblImportedFiles.Content = "No imported files"
        $script:controls.lblImportedFiles.Foreground = "Gray"
    } else {
        $script:controls.lblImportedFiles.Content = "$count file(s) imported"
        $script:controls.lblImportedFiles.Foreground = "DarkGreen"
    }
}

function Update-EventIDComboBox {
    $selectedCategory = Get-SelectedCategory
    
    if ($selectedCategory) {
        $script:controls.cbEventID.Items.Clear()
        $null = $script:controls.cbEventID.Items.Add("(All)")
        
        $script:categories[$selectedCategory].IDs | ForEach-Object {
            $null = $script:controls.cbEventID.Items.Add("$($_.ID) - $($_.Meaning)")
        }
        
        $script:controls.cbEventID.SelectedIndex = 0
    }
}

function Update-PaginationDisplay {
    $totalEvents = $script:allEvents.Count
    $totalPages = [Math]::Max(1, [Math]::Ceiling($totalEvents / $script:pageSize))
    
    $script:currentPage = [Math]::Max(1, [Math]::Min($script:currentPage, $totalPages))
    
    $script:controls.lblPageInfo.Content = "Page $($script:currentPage) of $totalPages"
    
    if ($totalEvents -eq 0) {
        $script:controls.txtStatusBar.Text = "No events to display"
        $script:controls.dgResults.ItemsSource = $null
    } else {
        $startIdx = ($script:currentPage - 1) * $script:pageSize + 1
        $endIdx = [Math]::Min($script:currentPage * $script:pageSize, $totalEvents)
        $script:controls.txtStatusBar.Text = "Showing $startIdx-$endIdx of $totalEvents events"
        
        $startIndex = $startIdx - 1
        $count = $endIdx - $startIdx + 1
        
        if ($count -gt 0 -and $startIndex -ge 0 -and $startIndex -lt $totalEvents) {
            # Create a NEW array (not a range reference) to avoid "underlying list invalid" errors
            $pageData = @()
            for ($i = $startIndex; $i -lt $endIdx -and $i -lt $totalEvents; $i++) {
                $pageData += $script:allEvents[$i]
            }
            
            # Set ItemsSource
            $script:controls.dgResults.ItemsSource = $pageData
            
            Write-Host "DEBUG: Set ItemsSource with $($pageData.Count) items (showing $startIdx to $endIdx of $totalEvents)" -ForegroundColor Yellow
        } else {
            Write-Host "DEBUG: Invalid range - startIndex=$startIndex, count=$count, totalEvents=$totalEvents" -ForegroundColor Red
            $script:controls.dgResults.ItemsSource = $null
        }
    }
    
    $script:controls.btnFirstPage.IsEnabled = $script:currentPage -gt 1
    $script:controls.btnPrevPage.IsEnabled = $script:currentPage -gt 1
    $script:controls.btnNextPage.IsEnabled = $script:currentPage -lt $totalPages
    $script:controls.btnLastPage.IsEnabled = $script:currentPage -lt $totalPages
}

function Get-SelectedCategory {
    if ($script:controls.rbAccountActivity.IsChecked) { return "AccountActivity" }
    if ($script:controls.rbADAccountChanges.IsChecked) { return "ADAccountChanges" }
    if ($script:controls.rbSecurityThreat.IsChecked) { return "SecurityThreatIndicators" }
    if ($script:controls.rbServerHealth.IsChecked) { return "ServerHealthReliability" }
    if ($script:controls.rbApplicationIssues.IsChecked) { return "ApplicationLevelIssues" }
    if ($script:controls.rbSysmon.IsChecked) { return "SysmonProcessActivity" }
    if ($script:controls.rbPowerShell.IsChecked) { return "PowerShellActivity" }
    if ($script:controls.rbDefender.IsChecked) { return "DefenderThreats" }
    if ($script:controls.rbFirewall.IsChecked) { return "WindowsFirewall" }
    if ($script:controls.rbTaskScheduler.IsChecked) { return "TaskScheduler" }
    if ($script:controls.rbRemoteDesktop.IsChecked) { return "RemoteDesktop" }
    if ($script:controls.rbCodeIntegrity.IsChecked) { return "CodeIntegrity" }
    if ($script:controls.rbWMI.IsChecked) { return "WMIActivity" }
    if ($script:controls.rbBitLocker.IsChecked) { return "BitLocker" }
    if ($script:controls.rbKerberosKDC.IsChecked) { return "KerberosKDC" }
    return ""
}

function Get-EventMeaning {
    param(
        [Parameter(Mandatory)]
        [int]$EventID,
        
        [Parameter()]
        [string]$Category = ""
    )
    
    if ($Category -and $script:categories.ContainsKey($Category)) {
        $meaning = ($script:categories[$Category].IDs | Where-Object { $_.ID -eq $EventID }).Meaning
        if ($meaning) { return $meaning }
    }
    
    foreach ($cat in $script:categories.Values) {
        $meaning = ($cat.IDs | Where-Object { $_.ID -eq $EventID }).Meaning
        if ($meaning) { return $meaning }
    }
    
    return "Event ID $EventID"
}

function Get-SelectedEventIDs {
    $selectedCategory = Get-SelectedCategory
    if (-not $selectedCategory) { return @() }
    
    $cat = $script:categories[$selectedCategory]
    
    if ($script:controls.cbEventID.SelectedItem -eq "(All)") {
        return $cat.IDs.ID
    } else {
        $selectedID = $script:controls.cbEventID.SelectedItem -split " - " | Select-Object -First 1
        return @([int]$selectedID)
    }
}

function Show-ProgressStatus {
    param([string]$Message)
    
    $script:controls.pbProgress.Visibility = "Visible"
    $script:controls.pbProgress.IsIndeterminate = $true
    $script:controls.lblStatus.Content = $Message
    $script:controls.txtStatusBar.Text = $Message
    $script:controls.btnSearch.IsEnabled = $false
    $script:controls.btnStopSearch.Visibility = "Visible"
    
    [System.Windows.Forms.Application]::DoEvents()
}

function Hide-ProgressStatus {
    $script:controls.pbProgress.Visibility = "Collapsed"
    $script:controls.pbProgress.IsIndeterminate = $false
    $script:controls.btnSearch.IsEnabled = $true
    $script:controls.btnStopSearch.Visibility = "Collapsed"
}

function Invoke-LiveMachineSearch {
    $selectedCategory = Get-SelectedCategory
    if (-not $selectedCategory) { return }
    
    $cat = $script:categories[$selectedCategory]
    $start = $script:controls.dpStart.SelectedDate
    $end = $script:controls.dpEnd.SelectedDate.AddDays(1)
    $computer = $script:controls.txtComputer.Text
    $eventIDs = Get-SelectedEventIDs
    
    if ([string]::IsNullOrWhiteSpace($computer)) { $computer = "localhost" }
    
    Show-ProgressStatus "Querying $computer..."
    $script:searchCancelled = $false
    
    try {
        $filter = @{
            LogName = $cat.Log
            ID = $eventIDs
            StartTime = $start
            EndTime = $end
        }
        
        $events = if ($computer -ne "localhost") {
            Get-WinEvent -FilterHashtable $filter -ComputerName $computer -ErrorAction Stop
        } else {
            Get-WinEvent -FilterHashtable $filter -ErrorAction Stop
        }
        
        if (-not $script:searchCancelled) {
            ConvertTo-EventResults -Events $events -Category $selectedCategory
        }
        
    } catch {
        if (-not $script:searchCancelled) {
            [System.Windows.MessageBox]::Show(
                "Error querying live machine: $($_.Exception.Message)", 
                "Search Error", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Error
            )
        }
    } finally {
        Hide-ProgressStatus
    }
}

function Invoke-ImportedFileSearch {
    $selectedCategory = Get-SelectedCategory
    if (-not $selectedCategory) { return }
    
    $start = $script:controls.dpStart.SelectedDate
    $end = $script:controls.dpEnd.SelectedDate.AddDays(1)
    $eventIDs = Get-SelectedEventIDs
    $cat = $script:categories[$selectedCategory]
    
    Show-ProgressStatus "Searching files..."
    $script:searchCancelled = $false
    
    try {
        $allFoundEvents = [System.Collections.ArrayList]::new()
        $totalFiles = $script:importedEVTXFiles.Count
        $currentFile = 0
        
        foreach ($filePath in $script:importedEVTXFiles) {
            if ($script:searchCancelled) { break }
            
            $currentFile++
            $fileName = Split-Path $filePath -Leaf
            $pct = [int](($currentFile / $totalFiles) * 100)
            
            Show-ProgressStatus "File $currentFile of $totalFiles - $fileName - $pct percent"
            
            try {
                # Use FilterHashtable which is MUCH faster for EVTX files
                $filterHash = @{
                    Path = $filePath
                    LogName = $cat.Log
                    ID = $eventIDs
                }
                
                # Only add date filter if it's not the default range
                if ($start -ne [DateTime]::MinValue) {
                    $filterHash['StartTime'] = $start
                }
                if ($end -ne [DateTime]::MaxValue) {
                    $filterHash['EndTime'] = $end
                }
                
                $events = Get-WinEvent -FilterHashtable $filterHash -ErrorAction SilentlyContinue
                
                if ($events) {
                    foreach ($evt in $events) {
                        $null = $allFoundEvents.Add($evt)
                    }
                }
                
            } catch {
                # If FilterHashtable fails, fall back to simple method
                try {
                    $events = Get-WinEvent -Path $filePath -ErrorAction SilentlyContinue | Where-Object {
                        $eventIDs -contains $_.Id -and
                        $_.LogName -eq $cat.Log -and
                        $_.TimeCreated -ge $start -and
                        $_.TimeCreated -lt $end
                    } | Select-Object -First 10000  # Limit to prevent freeze
                    
                    if ($events) {
                        foreach ($evt in $events) {
                            $null = $allFoundEvents.Add($evt)
                        }
                    }
                } catch {
                    # Ignore errors
                }
            }
            
            # Update UI after each file
            $script:controls.txtStatusBar.Text = "Found $($allFoundEvents.Count) events total..."
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        if (-not $script:searchCancelled) {
            if ($allFoundEvents.Count -gt 0) {
                ConvertTo-EventResults -Events $allFoundEvents -Category $selectedCategory
            } else {
                [System.Windows.MessageBox]::Show(
                    "No events found matching the search criteria.`n`nTry:`n- Expanding the date range`n- Selecting 'All' event IDs`n- Checking a different category", 
                    "No Results", 
                    [System.Windows.MessageBoxButton]::OK, 
                    [System.Windows.MessageBoxImage]::Information
                )
                Hide-ProgressStatus
            }
        }
        
    } catch {
        if (-not $script:searchCancelled) {
            [System.Windows.MessageBox]::Show(
                "Error searching files: $($_.Exception.Message)", 
                "Search Error", 
                [System.Windows.MessageBoxButton]::OK, 
                [System.Windows.MessageBoxImage]::Error
            )
        }
    } finally {
        Hide-ProgressStatus
    }
}

function ConvertTo-EventResults {
    param(
        [Parameter(Mandatory)]
        [AllowEmptyCollection()]
        [object[]]$Events,
        
        [Parameter(Mandatory)]
        [string]$Category
    )
    
    if ($script:searchCancelled) { return }
    
    Show-ProgressStatus "Processing $($Events.Count) events..."
    
    $script:allEvents.Clear()
    
    $processCount = 0
    foreach ($evt in $Events) {
        if ($script:searchCancelled) { break }
        
        $processCount++
        if ($processCount % 100 -eq 0) {
            Show-ProgressStatus "Processing: $processCount of $($Events.Count)..."
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        $meaning = Get-EventMeaning -EventID $evt.Id -Category $Category
        
        $null = $script:allEvents.Add([PSCustomObject]@{
            TimeCreated = $evt.TimeCreated
            LogName = $evt.LogName
            Source = $evt.ProviderName
            Id = $evt.Id
            Meaning = $meaning
            LevelDisplayName = $evt.LevelDisplayName
            Message = $evt.Message
            FullEvent = $evt
        })
    }
    
    if ($script:searchCancelled) { return }
    
    # Apply text filter
    $searchText = $script:controls.txtSearchText.Text
    if (-not [string]::IsNullOrWhiteSpace($searchText)) {
        Show-ProgressStatus "Applying text filter..."
        $filtered = [System.Collections.ArrayList]::new()
        foreach ($item in $script:allEvents) {
            if ($script:searchCancelled) { break }
            if ($item.Message -like "*$searchText*") {
                $null = $filtered.Add($item)
            }
        }
        $script:allEvents = $filtered
    }
    
    if (-not $script:searchCancelled) {
        $script:currentPage = 1
        Update-PaginationDisplay
        $script:controls.lblStatus.Content = "Complete - $($script:allEvents.Count) events"
        Hide-ProgressStatus
    }
}