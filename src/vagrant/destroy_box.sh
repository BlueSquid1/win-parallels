#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export VAGRANT_CWD="$SCRIPT_DIR"

if vagrant box list | grep -q "${1}"; then
    BOX_PATH="${1}" VM_NAME="${2}" vagrant box remove "${1}" --force --all
fi