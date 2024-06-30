#!/bin/bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Needed to resolve this issue: https://github.com/ansible/ansible/issues/76322#issuecomment-974147955
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

echo "download packer plugins"
packer init ${SCRIPT_DIR}

# echo "downloading esd file"
# $SCRIPT_DIR/download-windows-esd/download-windows-esd download en-us Professional ARM64 /tmp/windows-11-arm.esd

# echo "converting esd file to iso"
# $SCRIPT_DIR/windows-esd-to-iso/windows-esd-to-iso /tmp/windows-11-arm.esd /tmp/windows-11-arm.iso

echo "calculate sha256 for windows .iso"
sha256=$(shasum -a 256 /tmp/windows-11-arm.iso | awk '{print $1}')
echo "${sha256}"

echo "build autounattend.iso"
rm -f /tmp/unattended.iso
hdiutil makehybrid -iso -joliet -o /tmp/unattended.iso ${SCRIPT_DIR}/answer_files

echo "build the VM"
packer build -on-error=ask -var-file=${SCRIPT_DIR}/variables.pkrvars.hcl \
    -var "iso_url=/tmp/windows-11-arm.iso" \
    -var "iso_checksum=sha256:${sha256}" \
    -var "output_directory=/tmp/vm" \
    -var "output_vagrant_box=${SCRIPT_DIR}/../../box/Windows_11_ARM64.box" \
    ${SCRIPT_DIR}