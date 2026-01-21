<#
.SYNOPSIS
    Enhanced Windows Event Log Viewer v2.0 - OPTIMIZED Edition
    
.DESCRIPTION
    GUI tool for searching and analyzing Windows Event Logs from both live machines 
    and imported EVTX files. Features optimized search with XPath filtering and 
    background jobs for responsive UI.
    
.NOTES
    Version: 2.0 OPTIMIZED
    Author: Chris Munn
    Requires: PowerShell 5.1+, Administrator privileges for Security logs
#>

#Requires -Version 5.1

# Load required assemblies
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

# Get script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Enhanced Event Log Viewer v2.0" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Source additional script files in correct order
try {
    Write-Host "Loading components..." -ForegroundColor Yellow
    
    Write-Host "  [1/4] Categories..." -NoNewline
    . "$scriptPath\EventLogViewer_Categories.ps1"
    Write-Host " OK" -ForegroundColor Green
    
    Write-Host "  [2/4] Functions..." -NoNewline
    . "$scriptPath\EventLogViewer_Functions.ps1"
    Write-Host " OK" -ForegroundColor Green
    
    Write-Host "  [3/4] UI..." -NoNewline
    . "$scriptPath\EventLogViewer_UI.ps1"
    Write-Host " OK" -ForegroundColor Green
    
    Write-Host "  [4/4] Handlers..." -NoNewline
    . "$scriptPath\EventLogViewer_Handlers.ps1"
    Write-Host " OK" -ForegroundColor Green
    
} catch {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Error "Failed to load required script files: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Ensure all files are in the same directory:" -ForegroundColor Yellow
    Write-Host "  - EventLogViewer_V2.ps1" -ForegroundColor Gray
    Write-Host "  - EventLogViewer_Categories.ps1" -ForegroundColor Gray
    Write-Host "  - EventLogViewer_Functions.ps1" -ForegroundColor Gray
    Write-Host "  - EventLogViewer_UI.ps1" -ForegroundColor Gray
    Write-Host "  - EventLogViewer_Handlers.ps1" -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

# Initialize global variables
Write-Host ""
Write-Host "Initializing variables..." -NoNewline
$script:allEvents = [System.Collections.ArrayList]::new()
$script:autoRefreshTimer = $null
$script:currentPage = 1
$script:pageSize = 100
$script:importedEVTXFiles = [System.Collections.ArrayList]::new()
$script:searchCancelled = $false
Write-Host " OK" -ForegroundColor Green

# Main execution
try {
    Write-Host "Creating window..." -NoNewline
    
    # Initialize the main window
    Initialize-MainWindow
    Write-Host " OK" -ForegroundColor Green
    
    Write-Host "Attaching event handlers..." -NoNewline
    # Attach event handlers
    Initialize-EventHandlers
    Write-Host " OK" -ForegroundColor Green
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Application started successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Tips:" -ForegroundColor Yellow
    Write-Host "  • Import EVTX files to analyze offline logs" -ForegroundColor Gray
    Write-Host "  • Search uses FilterHashtable for speed" -ForegroundColor Gray
    Write-Host "  • Use Stop button to cancel searches" -ForegroundColor Gray
    Write-Host "  • 15 event categories including Kerberos/KDC" -ForegroundColor Gray
    Write-Host ""
    
    # Show the window (blocking call)
    $null = $script:window.ShowDialog()
    
} catch {
    Write-Host " FAILED" -ForegroundColor Red
    Write-Host ""
    Write-Error "Failed to start application: $($_.Exception.Message)"
    Write-Host ""
    Write-Host "Full error details:" -ForegroundColor Red
    Write-Host $_.Exception -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Stack trace:" -ForegroundColor Red
    Write-Host $_.ScriptStackTrace -ForegroundColor Yellow
    Write-Host ""
    
    [System.Windows.MessageBox]::Show(
        "Failed to start application:`n`n$($_.Exception.Message)`n`nCheck console for details.", 
        "Startup Error", 
        [System.Windows.MessageBoxButton]::OK, 
        [System.Windows.MessageBoxImage]::Error
    )
} finally {
    # Cleanup
    if ($script:autoRefreshTimer) {
        $script:autoRefreshTimer.Stop()
        $script:autoRefreshTimer = $null
    }
    Write-Host "Application closed." -ForegroundColor Gray
}