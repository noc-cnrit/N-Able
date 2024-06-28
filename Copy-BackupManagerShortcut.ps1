<#
.SYNOPSIS
    This script searches for the "Backup Manager" shortcut in the start menu and copies it to the public desktop.
.DESCRIPTION
    The script searches through the start menu of all users and the public start menu to find the "Backup Manager" shortcut. 
    Once found, it copies the shortcut to the public desktop. This script is designed to be run from an RMM solution.
.NOTES
    Author: [Your Name]
    Date: [Current Date]
    Version: 1.2
#>

# Function to copy shortcut if found
function Copy-Shortcut {
    param (
        [string]$ShortcutPath
    )
    $PublicDesktop = "$Env:PUBLIC\Desktop"
    if (Test-Path -Path $ShortcutPath) {
        try {
            Copy-Item -Path $ShortcutPath -Destination $PublicDesktop -Force
            Write-Output "Shortcut found and copied to public desktop: $ShortcutPath"
        } catch {
            Write-Output "Error copying shortcut: $ShortcutPath"
        }
    } else {
        Write-Output "Shortcut not found: $ShortcutPath"
    }
}

# Paths to search for the shortcut
$SearchPaths = @(
    "$Env:PROGRAMDATA\Microsoft\Windows\Start Menu\Programs\MXB\Backup Manager.lnk",
    "$Env:PROGRAMDATA\Microsoft\Windows\Start Menu\Backup Manager.lnk"
)

# Flag to indicate if shortcut was found
$ShortcutFound = $false

# Search through the specified paths
foreach ($Path in $SearchPaths) {
    if (Test-Path -Path $Path) {
        Copy-Shortcut -ShortcutPath $Path
        $ShortcutFound = $true
    }
}

# Final output indicating if shortcut was found
if (-not $ShortcutFound) {
    Write-Output "No 'Backup Manager' shortcut found on this system."
}
