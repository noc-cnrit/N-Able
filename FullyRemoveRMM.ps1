<#
.KEYWORDS
    NSight, RMM, Advanced Monitoring Agent, Uninstall, Remove, Forceful, Windows Service, PowerShell

.SYNOPSIS
    Forcefully removes the NSight RMM agent software and associated Windows service after attempting to run uninstallers.

.DESCRIPTION
    This script first attempts to run the uninstallers found in the registry for the NSight RMM agent software.
    If the uninstallers don't complete the removal or don't exist, the script then forcefully terminates related processes,
    deletes specific files and directories, and removes the "Advanced Monitoring Agent" Windows service.

    Caution: This script forcefully deletes files, terminates processes, and removes a Windows service. Use with caution
    and only in environments where such operations are safe and intended.

    To run this script, execute it from PowerShell with administrative privileges.
#>

# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force

function Invoke-Uninstallers {
    param (
        [string[]]$uninstallerPaths
    )

    foreach ($uninstallerPath in $uninstallerPaths) {
        if (Test-Path $uninstallerPath) {
            try {
                Write-Host "Running uninstaller: $uninstallerPath"
                Start-Process -FilePath $uninstallerPath -ArgumentList 'REMOVE=TRUE MODIFY=FALSE' -Wait
            }
            catch {
                Write-Host "Failed to run uninstaller at path: $uninstallerPath"
            }
        }
        else {
            Write-Host "Uninstaller not found at path: $uninstallerPath"
        }
    }
}

function Remove-NSightAgent {
    param (
        [string]$agentPath
    )

    # Terminate related processes
    Get-Process winagent, _new_winagent -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue

    # Kill any running executables in the directory
    Get-ChildItem -Path $agentPath -Filter *.exe -Recurse | ForEach-Object {
        $process = Get-Process -Name ($_.BaseName) -ErrorAction SilentlyContinue
        if ($process) {
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
    }

    # Delete the settings.ini file first
    $settingsFile = Join-Path -Path $agentPath -ChildPath "settings.ini"
    if (Test-Path $settingsFile) {
        Remove-Item $settingsFile -Force
    }

    # Remove all remaining files and folders in the directory
    Get-ChildItem -Path $agentPath -Recurse | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Define the uninstaller paths gleaned from the registry
$uninstallerPaths = @(
    # "C:\Program Files\Advanced Monitoring Agent Network Management\unins000.exe",
    "C:\ProgramData\{FE6265DF-9CF3-4C58-8B89-F6D8C0976573}\Agent.exe",
    "C:\PROGRA~2\ADVANC~1\RequestHandlerAgent\unins000.exe",
    "C:\PROGRA~2\ADVANC~1\patchman\unins000.exe",
    "C:\PROGRA~2\ADVANC~1\FileCacheServiceAgent\unins000.exe",
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvcCnfg.exe' /close_all", 
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvc.exe' /uninstall /silent", 
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvcUpdater.exe' /uninstall /silent", 
    "'C:\Program Files (x86)\Take Control Agent\BASupSrvcCnfg.exe' /agent_uninstall_reason LOCAL_UNINSTALL_MANUAL /notify_agent_uninstall"
    # "C:\Program Files (x86)\Take Control Agent\uninstall.exe"
)

# Attempt to run the uninstallers before forceful removal
Invoke-Uninstallers -uninstallerPaths $uninstallerPaths

# Main logic for deleting the service and removing agent directories
do {
    # Attempt to stop and delete the service
    $service = Get-Service -Name "Advanced Monitoring Agent" -ErrorAction SilentlyContinue
    if ($null -ne $service) {
        Stop-Service -Name "Advanced Monitoring Agent" -Force -ErrorAction SilentlyContinue
        $deleteOutput = & sc.exe delete "Advanced Monitoring Agent" 2>&1
        Write-Host $deleteOutput
    }

    # Define the paths
    $agentPaths = @(
        "C:\Program Files (x86)\Take Control Agent",
        "C:\Program Files (x86)\Advanced Monitoring Agent",
        "C:\Program Files (x86)\Advanced Monitoring Agent GP"
    )

    # Apply removal process to each path
    foreach ($path in $agentPaths) {
        Remove-NSightAgent -agentPath $path
    }

    # Check if the service has been deleted
    $service = Get-Service -Name "Advanced Monitoring Agent" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 5
} while ($null -ne $service)

Write-Host "Service 'Advanced Monitoring Agent' and associated software have been removed successfully."


