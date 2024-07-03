$ErrorActionPreference = 'Stop'

Write-Host "install Parallels Guest Agent"
$exe = "E:\PTAgent.exe"
$process = Start-Process $exe /install_silent -Wait -PassThru
if ($process.ExitCode -eq 0) {
  Write-Host "Installation Successful"
} elseif ($process.ExitCode -eq 3010) {
  Write-Warning "Installation Successful, Please reboot"
  Start-Sleep -Seconds 10
} else {
  Write-Error "Installation Failed: Error $($process.ExitCode)"
  Start-Sleep -Seconds 600
  exit $process.ExitCode
}

Write-Host "Make network interface private"
$connectionProfile = Get-NetConnectionProfile
While ($connectionProfile.Name -eq 'Identifying...') {
    Start-Sleep -Seconds 10
    $connectionProfile = Get-NetConnectionProfile
}
Set-NetConnectionProfile -Name $connectionProfile.Name -NetworkCategory Private

Write-Output 'Setup Windows Remote Management'
winrm quickconfig -quiet
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

Write-Output 'Allowing Windows Remote Management in the Windows Firewall'
netsh advfirewall firewall set rule group="Windows Remote Administration" new enable=yes
netsh advfirewall firewall set rule name="Windows Remote Management (HTTP-In)" new enable=yes action=allow
exit 0