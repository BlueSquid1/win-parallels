# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = File.read("./rebuild.ps1")

Vagrant.configure("2") do |config|
  config.vm.define "win-2022"
  config.vm.box = "stromweld/windows-2022"
  config.vm.provider "parallels"
  config.vm.boot_timeout = 120
  config.vm.communicator = "winrm"
  
  config.vm.network "forwarded_port", guest: 22, host: 22
  config.vm.network "private_network", ip: "192.168.50.2"
  config.vm.provision "shell", inline: $script
end
