#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export VAGRANT_CWD="$SCRIPT_DIR"

BOX_PATH="${1}" VM_NAME="${2}" vagrant destroy "${2}" --force

if vagrant box list | grep -q "(Status:\s200)"; then
    BOX_PATH="${1}" VM_NAME="${2}" vagrant box remove "${1}" --force --all
fi