# PowerShell script to clear all Windows Event Logs

# Get all event log names
$logs = Get-EventLog -List

# Loop through each log and clear it
foreach ($log in $logs) {
    # Clear the log
    try {
        Clear-EventLog -LogName $log.Log
        Write-Host "Cleared log: $($log.Log)"
    } catch {
        Write-Host "Failed to clear log: $($log.Log). Error: $_"
    }
}

Write-Host "All logs have been cleared."
