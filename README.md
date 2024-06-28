# win-parallels
Repo to automatically setup windows server 2022 inside Parallels hypervisor.

## useful commands
vagrant reload - redeploy an image

## pre-requirements
- Parellels Pro Edition (won't work with Parellels Standard Edition). 
    - can download from: https://www.parallels.com
- Vagrant. Can be installed by running:
    ```
    brew tap hashicorp/tap
    brew install hashicorp/tap/hashicorp-vagrant
    vagrant plugin install vagrant-parallels
    ```
- Wimlib for building the windows iso. Can be installed by running:
    ```
    brew install wimlib
    ```
- Packer for building a vagrant box. Can be installed by running:
    ```
    brew tap hashicorp/tap
    brew install hashicorp/tap/packer
    packer plugins install github.com/parallels/parallels
    ```
# Build instructions
cd win-parallels
vagrant up

