echo "setup SSH"
Add-WindowsCapability -Online -Name OpenSSH.Server
Get-Service -Name sshd | Set-Service -StartupType Automatic
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
Start-Service sshd

echo "setup RDP"
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0

echo "install choco"
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Create a powershell profile
New-Item -path $PROFILE -type file -force
Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\ProgramData\chocolatey\bin'"

echo "install dev tools"
choco install -y git
Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\Program Files\Git\bin'"
choco install -y netcat
choco install -y visualstudio2022buildtools
Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin'"
choco install -y firefox
choco install -y openvpn
Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\Program Files\OpenVPN\bin'"
#ROSE
#cd ~/Desktop
#reload terminal
#git clone https://github.com/BlueSquid1/rose.git
#cd rose
#& 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\setup.exe' modify --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" --config ".\client\rose.vsconfig" --quiet
#Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\Program Files\dotnet'"
#cd client
#reload terminal
#dotnet restore
#MSBuild.exe /property:Configuration=Release
#cp -r .\rose\bin\Release\net8.0 'C:\Program Files\Rose'
#Add-Content -Path $PROFILE -Value "`$env:Path += ';C:\Program Files\Rose'"
#reload terminal
#open regedit and set SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services\fAllowUnlistedRemotePrograms to 1