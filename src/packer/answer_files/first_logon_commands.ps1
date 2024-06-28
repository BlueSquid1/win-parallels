echo “got here” > C:\hello.txt
exit 0

G:\PTAgent.exe /install_silent

Write-Host "Performing the WinRM setup necessary to get the host ready for packer..."

# Make 100% sure we prevent Packer from connecting to WinRM while we
# attempt to configure everything
Disable-NetFirewallRule -DisplayGroup 'Windows Remote Management'

# Disable UAC
Set-ItemProperty -Path "registry::HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0

# parts of this are from https://github.com/luciusbono/Packer-Windows10/blob/master/configure-winrm.ps1
# and https://github.com/rgl/windows-2016-vagrant/blob/master/winrm.ps1

# Supress network location Prompt
New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Network\NewNetworkWindowOff" -Force

# The above suppresses the prompt but defaults to "Public" which prevents WinRM from being enabled even with the SkipNetworkProfileCheck arg
# This command sets any network connections detected to Private to allow WinRM to be configured and started
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory "Private"

# Does a lot: https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/enable-psremoting?view=powershell-6
Enable-PSRemoting -SkipNetworkProfileCheck -Force
# May not be necessary since we set the profile to Private above
Set-NetFirewallRule -Name "WINRM-HTTP-In-TCP" -RemoteAddress Any # allow winrm over public profile interfaces

Write-Host '* Deleting any pre-existing listeners'
winrm delete winrm/config/listener?Address=*+Transport=HTTP  2>$Null
winrm delete winrm/config/listener?Address=*+Transport=HTTPS 2>$Null

Write-Host '* Creating an HTTP listener'
winrm create winrm/config/listener?Address=*+Transport=HTTP | Out-Null
winrm create winrm/config/listener?Address=*+Transport=HTTPS | Out-Null

winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="2048"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
winrm set winrm/config/client/auth '@{Basic="true"}'

# Restart WinRM service
Stop-Service -Name "winrm"
Set-Service -Name "winrm" -StartupType "Automatic"
Start-Service -Name "winrm"

# Enable WinRM in Firewall for any remote address
Get-NetFirewallRule -DisplayGroup "Windows Remote Management" | Get-NetFirewallAddressFilter | Set-NetFirewallAddressFilter -RemoteAddress Any
Enable-NetFirewallRule -DisplayGroup "Windows Remote Management"

# Reset auto logon count
# https://docs.microsoft.com/en-us/windows-hardware/customize/desktop/unattend/microsoft-windows-shell-setup-autologon-logoncount#logoncount-known-issue
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name AutoLogonCount -Value 0

# Allow time to view output before window is closed
Start-Sleep -Seconds 3

New-Item -ItemType Directory -Force -Path "c:\parallels-tools"

cmd.exe /c wmic useraccount where "name='vagrant'" set PasswordExpires=FALSE

# install vagrant public key in windows 11 OpenSSh
$pubkey_url="https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub"

#check if the .ssh folder exists
if (!(Test-Path "$env:USERPROFILE\.ssh")) {
    New-Item -Path "$env:USERPROFILE\.ssh" -ItemType Directory
}

#get the public key to a file ignoring ssl
Invoke-WebRequest -Uri $pubkey_url -OutFile "$env:USERPROFILE\.ssh\authorized_keys" -UseBasicParsing
#get the public key to the administrators key file
Invoke-WebRequest -Uri $pubkey_url -OutFile "$env:PROGRAMDATA\ssh\administrators_authorized_keys" -UseBasicParsing

$config = @"
# This is the sshd server system-wide configuration file.  See
# sshd_config(5) for more information.

# The strategy used for options in the default sshd_config shipped with
# OpenSSH is to specify options with their default value where
# possible, but leave them commented.  Uncommented options override the
# default value.

#Port 22
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::

#HostKey __PROGRAMDATA__/ssh/ssh_host_rsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_dsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_ecdsa_key
#HostKey __PROGRAMDATA__/ssh/ssh_host_ed25519_key

# Ciphers and keying
#RekeyLimit default none

# Logging
#SyslogFacility AUTH
#LogLevel INFO

# Authentication:

#LoginGraceTime 2m
#PermitRootLogin prohibit-password
#StrictModes yes
#MaxAuthTries 6
#MaxSessions 10

PubkeyAuthentication yes

# The default is to check both .ssh/authorized_keys and .ssh/authorized_keys2
# but this is overridden so installations will only check .ssh/authorized_keys
AuthorizedKeysFile	.ssh/authorized_keys

#AuthorizedPrincipalsFile none

# For this to work you will also need host keys in %programData%/ssh/ssh_known_hosts
#HostbasedAuthentication no
# Change to yes if you don't trust ~/.ssh/known_hosts for
# HostbasedAuthentication
#IgnoreUserKnownHosts no
# Don't read the user's ~/.rhosts and ~/.shosts files
#IgnoreRhosts yes

# To disable tunneled clear text passwords, change to no here!
# PasswordAuthentication no
PermitEmptyPasswords no

# GSSAPI options
#GSSAPIAuthentication no

#AllowAgentForwarding yes
#AllowTcpForwarding yes
#GatewayPorts no
#PermitTTY yes
#PrintMotd yes
#PrintLastLog yes
#TCPKeepAlive yes
#UseLogin no
#PermitUserEnvironment no
#ClientAliveInterval 0
#ClientAliveCountMax 3
#UseDNS no
#PidFile /var/run/sshd.pid
#MaxStartups 10:30:100
#PermitTunnel no
#ChrootDirectory none
#VersionAddendum none

# no default banner path
#Banner none

# override default of no subsystems
Subsystem	sftp	sftp-server.exe

# Example of overriding settings on a per-user basis
#Match User anoncvs
#	AllowTcpForwarding no
#	PermitTTY no
#	ForceCommand cvs server
"@

#write the config to the file
$config | Out-File -FilePath "$env:ProgramData\ssh\sshd_config" -Encoding ascii
#restart the sshd service
Restart-Service sshd
#allow the firewall rule
New-NetFirewallRule -DisplayName 'OpenSSH Server (sshd)' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -Enabled True

#turn off the firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
#turn on the firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

Write-Host 'Disabling hibernation...'
powercfg /hibernate off

Write-Host 'Setting the power plan to high performance...'
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

#
# reclaim the free disk space.

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

Add-WindowsCapability -Online -Name "OpenSSH.Client~~~~0.0.1.0"
Add-WindowsCapability -Online -Name "OpenSSH.Server~~~~0.0.1.0"
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22

exit 0