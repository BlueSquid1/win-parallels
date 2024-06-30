$ErrorActionPreference = 'Stop'

Write-Host "Disable UAC"
Set-ItemProperty -Path "registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

Write-Host "Make network interface private"
$connectionProfile = Get-NetConnectionProfile
While ($connectionProfile.Name -eq 'Identifying...') {
    Start-Sleep -Seconds 10
    $connectionProfile = Get-NetConnectionProfile
}
Set-NetConnectionProfile -Name $connectionProfile.Name -NetworkCategory Private

Write-Output 'Setup Windows Remote Management'
winrm quickconfig -quiet
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'

Write-Host "Disable firewall"
Set-NetFirewallProfile -Profile Domain, Public, Private -Enabled False

# Write-Host "Install OpenSSH server"
# Add-WindowsCapability -Online -Name OpenSSH.Server
# Get-Service -Name sshd | Set-Service -StartupType Automatic

# Write-Host "install vagrant public key"
# $pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub"
# if (!(Test-Path "$env:USERPROFILE\.ssh")) {
#     New-Item -Path "$env:USERPROFILE\.ssh" -ItemType Directory
# }
# #get the public key to a file ignoring ssl
# Invoke-WebRequest -Uri $pubkey_url -OutFile "$env:USERPROFILE\.ssh\authorized_keys" -UseBasicParsing
# #get the public key to the administrators key file
# Invoke-WebRequest -Uri $pubkey_url -OutFile "$env:PROGRAMDATA\ssh\administrators_authorized_keys" -UseBasicParsing

# $config = @"
# PubkeyAuthentication yes
# "@
# #write the config to the file
# $config | Out-File -FilePath "$env:ProgramData\ssh\sshd_config" -Encoding ascii

# Write-Host "Start OpenSSH server"
# Start-Service sshd

exit 0