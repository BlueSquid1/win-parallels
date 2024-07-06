# win-parallels
Repo to automatically setup windows 11 inside Parallels hypervisor.

## pre-requirements
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

## Build instructions
### Build image from scratch

`./win-rebuild`

### Launch container
`./win-start`

### Pause container
`./win-stop`
