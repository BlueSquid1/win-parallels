Write-Host "Install parallels agent"
E:\PTAgent.exe /install_silent

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

cmd.exe /c wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE

Write-Host 'Disabling hibernation'
powercfg /hibernate off

Write-Host 'Setting the power plan to high performance...'
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Write-Host "Waiting for other commands to be ready before continuing..."
# $commands = @("winget")

# foreach ($command in $commands) {
#   while($true) {
#     if(Get-Command $command -ErrorAction SilentlyContinue) {
#       Write-Host "$command is available!"
#       break
#     }
#     else {
#       Write-Host "$command is not available yet. Sleeping for 5 seconds..."
#       Start-Sleep -Seconds 5
#     }
#   }
# }

#update windows
#update notepad
exit 0


Write-Host 'Reclaiming the free disk space...'
$results = defrag.exe C: /H /L
if ($results -eq 'The operation completed successfully.')
{
    $results
}
else
{
    if ((Get-CimInstance Win32_OperatingSystem).version -eq "6.3.9600")
    {
        return
    }
    else
    {
        Write-Host 'Zero filling the free disk space...'
        (New-Object System.Net.WebClient).DownloadFile('https://download.sysinternals.com/files/SDelete.zip', "$env:TEMP\SDelete.zip")
        Expand-Archive "$env:TEMP\SDelete.zip" $env:TEMP
        Remove-Item "$env:TEMP\SDelete.zip"
        &"$env:TEMP\sdelete64.exe" -accepteula -z C:
    }
}