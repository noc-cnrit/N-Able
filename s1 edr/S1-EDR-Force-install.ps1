$WarningPreference = "SilentlyContinue"
$ErrorActionPreference = "SilentlyContinue"
$InformationPreference = "SilentlyContinue"
$site_token=$args[0]

# '==================================================================================================================================================================
# 'Disclaimer
# 'The sample scripts are not supported under any N-able support program or service. 
# 'The sample scripts are provided AS IS without warranty of any kind. 
# 'N-able further disclaims all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose. 
# 'The entire risk arising out of the use or performance of the sample scripts and documentation stays with you. 
# 'In no event shall N-able or anyone else involved in the creation, production, or delivery of the scripts be liable for any damages whatsoever 
# '(including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) 
# 'arising out of the use of or inability to use the sample scripts or documentation.
# '==================================================================================================================================================================

## Check if site token is Valid - If not valid Fail
if($site_token -like ""){
Write-host "NO Site token Provided"
EXIT 1001
}
$SiteTokenLine = "Site Token Set to " + $site_token 


#### Download the  sentenal agent
$download_url = "https://sis.n-able.com/SentinelOne/SentinelOne_Windows_Latest64.exe"
$tmpFile = $env:temp + '\S1_Installer.exe'
$DownloadLocationLine = "Downloading Installer to $tmpFile"
Invoke-RestMethod -Uri $download_url -Method Get -OutFile $tmpFile
$DownloadStatusLine = "File Downloaded"

#### Create process with Event logging
$ProcessConfig = New-Object System.Diagnostics.ProcessStartInfo
$ProcessConfig.FileName = $tmpFile
$ProcessConfig.RedirectStandardError = $true
$ProcessConfig.RedirectStandardOutput = $true
$ProcessConfig.UseShellExecute = $false
$ProcessConfig.Arguments = '-q -t ' +$site_token + ' --dont_fail_on_config_preserving_failures --force'
$Process = New-Object System.Diagnostics.Process
$Process.StartInfo = $ProcessConfig
$Process.Start() | Out-Null
$Process.WaitForExit()
$ExitOutputLine = $Process.StandardOutput.ReadToEnd()
$ExitErrorLine = $Process.StandardError.ReadToEnd()

$ExitCodeLine = $Process.ExitCode

### Check For error code of process, to gicve RMM Check a output header
if($Process.ExitCode -like 0){$ReturnDataLineHeader = " Installed OK - Make sure EDRI is Enabled"}
if($Process.ExitCode -like 2002){$ReturnDataLineHeader = "Reboot the endpoint and try to install again."}
if($Process.ExitCode -like 2005){$ReturnDataLineHeader = "Uninstallation failed - authentication error"}
if($Process.ExitCode -notlike 2002 -and $ExitCodeLine -notlike 0  -and $ExitCodeLine -notlike 2005){$ReturnDataLineHeader = $ExitCodeLine }

### Create Task Output
Write-Host $ReturnDataLineHeader
Write-Host '-------------'
write-host $SiteTokenLine 
Write-Host $DownloadLocationLine
write-Host $DownloadStatusLine

Write-Host '-------------'
Write-Host $ExitOutputLine
Write-Host $ExitErrorLine
Write-Host "ExitCode - $ExitCodeLine"


### Exit process based on Error code
if($ExitCodeLine -like 0){Exit 0}
if($ExitCodeLine -like 2002){Exit 1001}
Exit 1001


