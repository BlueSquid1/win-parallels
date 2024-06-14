# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = File.read(__dir__ + "/rebuild.ps1")

Vagrant.configure("2") do |config|
  config.vm.define "win-11"
  config.vm.box = "stromweld/windows-11"
  config.vm.boot_timeout = 150
  
  config.vm.network "private_network", ip: "192.168.50.2"

  config.vm.synced_folder "/tmp/shared", "C:\\windows\\Temp\\shared", create: true

  config.vm.provision "shell", inline: $script  
end
