#!/bin/bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# echo "download parallels plugin to packer"
# packer init ${SCRIPT_DIR}

# echo "downloading esd file"
# $SCRIPT_DIR/download-windows-esd/download-windows-esd download en-us Professional ARM64 /tmp/windows-11-arm.esd

# echo "converting esd file to iso"
# $SCRIPT_DIR/windows-esd-to-iso/windows-esd-to-iso /tmp/windows-11-arm.esd /tmp/windows-11-arm.iso

echo "calculate sha256"
sha256=$(shasum -a 256 /tmp/windows-11-arm.iso | awk '{print $1}')

echo "build autounattend.iso"
hdiutil makehybrid -iso -joliet -o /tmp/unattended.iso ${SCRIPT_DIR}/answer_files

echo "build the VM"
packer build -var-file=${SCRIPT_DIR}/variables.pkrvars.hcl -var "iso_checksum=sha256:${sha256}" ${SCRIPT_DIR}