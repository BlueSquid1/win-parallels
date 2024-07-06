#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export VAGRANT_CWD="$SCRIPT_DIR"

BOX_PATH="${1}" VM_NAME="${2}" vagrant destroy "${2}" --force
BOX_PATH="${1}" VM_NAME="${2}" vagrant box destroy "${1}" --force