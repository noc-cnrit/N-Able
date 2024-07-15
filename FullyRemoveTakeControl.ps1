<#
.NAME
    FullyRemoveTakeControl.ps1

.KEYWORDS
    NSight, RMM, Take control, Uninstall, Remove, Forceful, Windows Service, PowerShell

.SYNOPSIS
    Forcefully removes the Take Control remote control software.

.DESCRIPTION
    This script cleans up issues for when Take Control does not work like it should.
#>

function Invoke-Uninstallers {
    param (
        [string[]]$uninstallerPaths
    )
    foreach ($uninstallerPath in $uninstallerPaths) {
        if (Test-Path $uninstallerPath) {
            try {
                Write-Host "Running uninstaller: $uninstallerPath"
                Start-Process -FilePath $uninstallerPath -ArgumentList 'REMOVE=TRUE MODIFY=FALSE' -Wait
            } catch {
                Write-Host "Failed to run uninstaller at path: $uninstallerPath"
            }
        } else {
            Write-Host "Uninstaller not found at path: $uninstallerPath"
        }
    }
}

function Remove-NSightAgent {
    param (
        [string]$agentPath
    )
    Get-Process winagent, _new_winagent -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-ChildItem -Path $agentPath -Filter *.exe -Recurse | ForEach-Object {
        $process = Get-Process -Name ($_.BaseName) -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
    }
    $settingsFile = Join-Path -Path $agentPath -ChildPath "settings.ini"
    if (Test-Path $settingsFile) {
        Remove-Item $settingsFile -Force
    }
    Get-ChildItem -Path $agentPath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

$uninstallerPaths = @(
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvcCnfg.exe' /close_all", 
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvc.exe' /uninstall /silent", 
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvcUpdater.exe' /uninstall /silent", 
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvcCnfg.exe' /agent_uninstall_reason LOCAL_UNINSTALL_MANUAL /notify_agent_uninstall"
)

Invoke-Uninstallers -uninstallerPaths $uninstallerPaths

$agentPaths = @(
    "C:\Program Files (x86)\Take Control Agent"
)

foreach ($path in $agentPaths) {
    Remove-NSightAgent -agentPath $path
}

Write-Host "Service 'Advanced Monitoring Agent' and associated software have been removed successfully."
