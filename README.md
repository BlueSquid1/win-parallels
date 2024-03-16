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
# Build instructions
cd win-parallels
vagrant up

