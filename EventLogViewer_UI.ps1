# Enhanced Event Log Viewer v2.0


function Initialize-MainWindow {
    <#
    .SYNOPSIS
        Initializes and configures the main application window
    #>
    
    # XAML definition for main window
    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Enhanced Event Log Viewer v2.0 - SOC Edition" Height="850" Width="1400" WindowStartupLocation="CenterScreen">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <GroupBox Grid.Row="0" Header="Windows Security Events" Margin="10,10,10,5" Padding="5">
            <StackPanel Orientation="Horizontal">
                <RadioButton x:Name="rbAccountActivity" Content="Account Activity" GroupName="Category" IsChecked="True" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbADAccountChanges" Content="AD Account Changes" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbSecurityThreat" Content="Security Threats" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbServerHealth" Content="Server Health" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbApplicationIssues" Content="Application Issues" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
            </StackPanel>
        </GroupBox>
        
        <GroupBox Grid.Row="1" Header="SOC and Forensic Logs" Margin="10,5" Padding="5" Background="#FFF8DC">
            <StackPanel Orientation="Horizontal">
                <RadioButton x:Name="rbSysmon" Content="Sysmon Process Activity" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbPowerShell" Content="PowerShell Activity" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbDefender" Content="Defender Threats" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbFirewall" Content="Windows Firewall" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbTaskScheduler" Content="Task Scheduler" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
            </StackPanel>
        </GroupBox>
        
        <GroupBox Grid.Row="2" Header="Advanced Monitoring" Margin="10,5" Padding="5" Background="#E6F3FF">
            <StackPanel Orientation="Horizontal">
                <RadioButton x:Name="rbRemoteDesktop" Content="Remote Desktop" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbCodeIntegrity" Content="Code Integrity" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbWMI" Content="WMI Activity" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
                <RadioButton x:Name="rbBitLocker" Content="BitLocker" GroupName="Category" Margin="10,5" VerticalAlignment="Center"/>
            </StackPanel>
        </GroupBox>
        
        <StackPanel Grid.Row="3" Orientation="Horizontal" Margin="10,5">
            <Label Content="Source:" FontWeight="Bold" Margin="5,0" VerticalAlignment="Center"/>
            <ComboBox x:Name="cbSource" Width="150" Margin="5,0" SelectedIndex="0" VerticalAlignment="Center">
                <ComboBoxItem Content="Live Machine"/>
                <ComboBoxItem Content="Imported Files"/>
            </ComboBox>
            <Label Content="Computer:" Margin="20,0,5,0" VerticalAlignment="Center"/>
            <TextBox x:Name="txtComputer" Width="150" Margin="5,0" Text="localhost" VerticalAlignment="Center"/>
            <Label Content="Start:" Margin="20,0,5,0" VerticalAlignment="Center"/>
            <DatePicker x:Name="dpStart" Margin="5,0" VerticalAlignment="Center"/>
            <Label Content="End:" Margin="10,0,5,0" VerticalAlignment="Center"/>
            <DatePicker x:Name="dpEnd" Margin="5,0" VerticalAlignment="Center"/>
        </StackPanel>
        
        <StackPanel Grid.Row="4" Orientation="Horizontal" Margin="10,5">
            <Label Content="Event ID:" Margin="5,0" VerticalAlignment="Center"/>
            <ComboBox x:Name="cbEventID" Width="250" Margin="5,0" VerticalAlignment="Center"/>
            <Label Content="Text Search:" Margin="20,0,5,0" VerticalAlignment="Center"/>
            <TextBox x:Name="txtSearchText" Width="250" Margin="5,0" VerticalAlignment="Center"/>
        </StackPanel>
        
        <StackPanel Grid.Row="5" Orientation="Horizontal" Margin="10,5">
            <Button x:Name="btnSearch" Content="Search" Width="90" Height="32" Margin="5,0" FontWeight="Bold" Background="#4CAF50" Foreground="White"/>
            <Button x:Name="btnStopSearch" Content="Stop" Width="70" Height="32" Margin="5,0" Background="#F44336" Foreground="White" Visibility="Collapsed"/>
            <Button x:Name="btnClear" Content="Clear" Width="70" Height="32" Margin="5,0"/>
            <Separator Width="20" Background="Transparent"/>
            <Button x:Name="btnImportEVTX" Content="Import EVTX" Width="110" Height="32" Margin="5,0"/>
            <Button x:Name="btnManageFiles" Content="Manage Files" Width="110" Height="32" Margin="5,0"/>
            <Separator Width="20" Background="Transparent"/>
            <Button x:Name="btnExportCSV" Content="Export CSV" Width="90" Height="32" Margin="5,0"/>
            <Button x:Name="btnExportExcel" Content="Export Excel" Width="95" Height="32" Margin="5,0"/>
            <Button x:Name="btnWebSearch" Content="Web Search" Width="105" Height="32" Margin="5,0"/>
            <CheckBox x:Name="chkAutoRefresh" Content="Auto-Refresh (30s)" Margin="20,0,5,0" VerticalAlignment="Center"/>
        </StackPanel>
        
        <StackPanel Grid.Row="6" Orientation="Horizontal" Margin="10,5" Background="#FFFACD" Height="30">
            <Label x:Name="lblImportedFiles" Content="No imported files" Margin="10,0" FontStyle="Italic" VerticalAlignment="Center"/>
            <Label x:Name="lblStatus" Content="" Margin="20,0" Foreground="Blue" VerticalAlignment="Center"/>
        </StackPanel>
        
        <ProgressBar x:Name="pbProgress" Grid.Row="7" Height="20" Margin="10,5" Visibility="Collapsed"/>
        
        <!-- Results Grid - Expands to fill space -->
        <DataGrid x:Name="dgResults" Grid.Row="8" AutoGenerateColumns="False" IsReadOnly="True" 
                  Margin="10,5,10,5"
                  AlternatingRowBackground="#F0F0F0" RowHeight="25" GridLinesVisibility="Horizontal"
                  HorizontalGridLinesBrush="#E0E0E0" EnableRowVirtualization="True" VirtualizingPanel.IsVirtualizing="True"
                  CanUserResizeRows="False" VerticalScrollBarVisibility="Auto">
            <DataGrid.RowStyle>
                <Style TargetType="DataGridRow">
                    <Setter Property="BorderThickness" Value="0,0,0,1"/>
                    <Setter Property="BorderBrush" Value="#D0D0D0"/>
                    <Style.Triggers>
                        <Trigger Property="IsMouseOver" Value="True">
                            <Setter Property="Background" Value="#E3F2FD"/>
                        </Trigger>
                        <Trigger Property="IsSelected" Value="True">
                            <Setter Property="Background" Value="#BBDEFB"/>
                        </Trigger>
                    </Style.Triggers>
                </Style>
            </DataGrid.RowStyle>
            <DataGrid.Columns>
                <DataGridTextColumn Header="Time" Binding="{Binding TimeCreated}" Width="150" MinWidth="140"/>
                <DataGridTextColumn Header="Log" Binding="{Binding LogName}" Width="100" MinWidth="80"/>
                <DataGridTextColumn Header="Source" Binding="{Binding Source}" Width="180" MinWidth="120"/>
                <DataGridTextColumn Header="ID" Binding="{Binding Id}" Width="60" MinWidth="50"/>
                <DataGridTextColumn Header="Meaning" Binding="{Binding Meaning}" Width="200" MinWidth="150"/>
                <DataGridTextColumn Header="Level" Binding="{Binding LevelDisplayName}" Width="80" MinWidth="60"/>
                <DataGridTextColumn Header="Message" Binding="{Binding Message}" Width="*" MinWidth="200"/>
            </DataGrid.Columns>
        </DataGrid>
        
        <!-- Pagination Navigation Bar - Always at bottom -->
        <Border Grid.Row="9" Background="#F5F5F5" BorderBrush="#D0D0D0" BorderThickness="0,1,0,0" Padding="8" Height="50">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                    <ColumnDefinition Width="*"/>
                </Grid.ColumnDefinitions>
                
                <!-- Status on left -->
                <TextBlock x:Name="txtStatusBar" Grid.Column="0" Text="Ready" FontWeight="SemiBold" FontSize="13" VerticalAlignment="Center" Margin="10,0"/>
                
                <!-- Pagination controls in center -->
                <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
                    <Button x:Name="btnFirstPage" Content="First" Width="70" Height="30" Margin="5,0" FontSize="13"/>
                    <Button x:Name="btnPrevPage" Content="Prev" Width="70" Height="30" Margin="5,0" FontSize="13"/>
                    <Label x:Name="lblPageInfo" Content="Page 1 of 1" Margin="15,0" VerticalAlignment="Center" FontWeight="Bold" FontSize="14"/>
                    <Button x:Name="btnNextPage" Content="Next" Width="70" Height="30" Margin="5,0" FontSize="13"/>
                    <Button x:Name="btnLastPage" Content="Last" Width="70" Height="30" Margin="5,0" FontSize="13"/>
                    <Separator Width="30" Background="Transparent"/>
                    <Label Content="Per Page:" Margin="5,0" VerticalAlignment="Center" FontSize="13"/>
                    <ComboBox x:Name="cbPageSize" Width="80" Height="28" Margin="5,0" SelectedIndex="1" VerticalAlignment="Center" FontSize="13">
                        <ComboBoxItem Content="50"/>
                        <ComboBoxItem Content="100"/>
                        <ComboBoxItem Content="250"/>
                        <ComboBoxItem Content="500"/>
                    </ComboBox>
                </StackPanel>
                
                <!-- Empty space on right for balance -->
                <StackPanel Grid.Column="2"/>
            </Grid>
        </Border>
    </Grid>
</Window>
"@
    
    # Load XAML
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $script:window = [Windows.Markup.XamlReader]::Load($reader)
    
    # Create controls hashtable - ALL 14 CATEGORIES
    $script:controls = @{
        rbAccountActivity = $script:window.FindName("rbAccountActivity")
        rbADAccountChanges = $script:window.FindName("rbADAccountChanges")
        rbSecurityThreat = $script:window.FindName("rbSecurityThreat")
        rbServerHealth = $script:window.FindName("rbServerHealth")
        rbApplicationIssues = $script:window.FindName("rbApplicationIssues")
        rbSysmon = $script:window.FindName("rbSysmon")
        rbPowerShell = $script:window.FindName("rbPowerShell")
        rbDefender = $script:window.FindName("rbDefender")
        rbFirewall = $script:window.FindName("rbFirewall")
        rbTaskScheduler = $script:window.FindName("rbTaskScheduler")
        rbRemoteDesktop = $script:window.FindName("rbRemoteDesktop")
        rbCodeIntegrity = $script:window.FindName("rbCodeIntegrity")
        rbWMI = $script:window.FindName("rbWMI")
        rbBitLocker = $script:window.FindName("rbBitLocker")
        cbSource = $script:window.FindName("cbSource")
        txtComputer = $script:window.FindName("txtComputer")
        dpStart = $script:window.FindName("dpStart")
        dpEnd = $script:window.FindName("dpEnd")
        cbEventID = $script:window.FindName("cbEventID")
        txtSearchText = $script:window.FindName("txtSearchText")
        btnSearch = $script:window.FindName("btnSearch")
        btnStopSearch = $script:window.FindName("btnStopSearch")
        btnClear = $script:window.FindName("btnClear")
        btnImportEVTX = $script:window.FindName("btnImportEVTX")
        btnManageFiles = $script:window.FindName("btnManageFiles")
        btnExportCSV = $script:window.FindName("btnExportCSV")
        btnExportExcel = $script:window.FindName("btnExportExcel")
        btnWebSearch = $script:window.FindName("btnWebSearch")
        chkAutoRefresh = $script:window.FindName("chkAutoRefresh")
        lblImportedFiles = $script:window.FindName("lblImportedFiles")
        lblStatus = $script:window.FindName("lblStatus")
        pbProgress = $script:window.FindName("pbProgress")
        dgResults = $script:window.FindName("dgResults")
        btnFirstPage = $script:window.FindName("btnFirstPage")
        btnPrevPage = $script:window.FindName("btnPrevPage")
        lblPageInfo = $script:window.FindName("lblPageInfo")
        btnNextPage = $script:window.FindName("btnNextPage")
        btnLastPage = $script:window.FindName("btnLastPage")
        cbPageSize = $script:window.FindName("cbPageSize")
        txtStatusBar = $script:window.FindName("txtStatusBar")
    }
    
    # Set default values
    $script:controls.dpStart.SelectedDate = (Get-Date).AddDays(-3)
    $script:controls.dpEnd.SelectedDate = Get-Date
    
    # Initialize displays
    Update-EventIDComboBox
    Update-ImportedFilesDisplay
    Update-PaginationDisplay
    
    # Window closing event
    $script:window.Add_Closing({
        if ($script:autoRefreshTimer) {
            $script:autoRefreshTimer.Stop()
            $script:autoRefreshTimer = $null
        }
        if ($script:searchJob) {
            $script:searchJob | Stop-Job -ErrorAction SilentlyContinue
            $script:searchJob | Remove-Job -Force -ErrorAction SilentlyContinue
        }
    })
}