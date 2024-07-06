# win-parallels
Repo to automatically setup windows server 2022 inside Parallels hypervisor.

## useful commands
vagrant reload - redeploy an image

## pre-requirements
- Windows 11 arm .iso file. Refer to: https://github.com/Parallels/packer-examples/blob/main/windows/README.md#windows-11-on-arm-iso
- Parellels Pro Edition (won't work with Parellels Standard Edition). 
    - can download from: https://www.parallels.com
- Vagrant. Can be installed by running:
    ```
    brew tap hashicorp/tap
    brew install hashicorp/tap/hashicorp-vagrant
    vagrant plugin install vagrant-parallels
    ```
- Packer for building a vagrant box. Can be installed by running:
    ```
    brew tap hashicorp/tap
    brew install hashicorp/tap/packer
    packer plugins install github.com/parallels/parallels
    ```
- Ansible is used to configure the windows VM. Can be installed by running:
   ```
   brew install ansible
   ```
- Wimlib to convert .esd to .iso
   ```
   brew install wimlib
   ```
- host shell lets vagrant script run commands on host
   ```
   vagrant plugin install vagrant-host-shell
   ```
# Build instructions
cd win-parallels
vagrant up

