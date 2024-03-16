echo "setup SSH"
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Get-Service -Name sshd | Set-Service -StartupType Automatic
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Start-Service sshd

echo "setup RDP"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0

echo "install choco"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
New-Item -path $PROFILE -type file -force
Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\ProgramData\chocolatey\bin'"

echo "install dev tools"
choco install -y git
choco install -y netcat
#choco install -y visualstudio2022buildtools
#Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin'"
#Export-ModuleMember -Alias refreshenv -Function 'Update-SessionEnvironment', 'TabExpansion'
#Import-Module C:\ProgramData\chocolatey\helpers\chocolateyProfile.psm1
#refreshenv

#ROSE
#Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\Program Files\Rose'"
#reload terminal