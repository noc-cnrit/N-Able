# Define the path for the output batch file
$scriptPath = $MyInvocation.MyCommand.Path
$batchFilePath = Join-Path -Path (Split-Path -Parent $scriptPath) -ChildPath "uninstall_take_control_viewer.bat"

# Retrieve uninstall strings from the registry
$uninstallKeys = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall",
    "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
)

$targetAppName = "Take Control Viewer"
$uninstallString = $null
$applications = @()

foreach ($key in $uninstallKeys) {
    $subKeys = Get-ChildItem -Path $key
    foreach ($subKey in $subKeys) {
        $appProperties = Get-ItemProperty -Path $subKey.PSPath -ErrorAction SilentlyContinue
        $appName = $appProperties.DisplayName
        $uninstallStr = $appProperties.UninstallString
        if ($appName) {
            $applications += [PSCustomObject]@{
                Name = $appName
                UninstallString = $uninstallStr
            }
        }
        if ($appName -eq $targetAppName) {
            $uninstallString = $uninstallStr
            if (!$uninstallString) {
                $uninstallString = $appProperties.QuietUninstallString
            }
            break
        }
    }
    if ($uninstallString) { break }
}

if ($applications) {
    Write-Output "Applications found (sorted by name):"
    $applications | Sort-Object Name | Format-Table -AutoSize
}

if ($uninstallString) {
    # Format the uninstall string as a batch file command with quiet switches
    if ($uninstallString -like "*.exe*") {
        $formattedString = "`"$uninstallString`" /quiet /norestart"
    } elseif ($uninstallString -like "*.msi*") {
        $formattedString = "msiexec /x `$uninstallString /quiet /norestart"
    } else {
        $formattedString = "`"$uninstallString`""
    }

    # Write the batch file
    Set-Content -Path $batchFilePath -Value $formattedString

    Write-Output "Batch file created at: $batchFilePath"
} else {
    Write-Output "Take Control Viewer uninstall string not found."
}
