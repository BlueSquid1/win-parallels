#!/bin/bash
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export VAGRANT_CWD="$SCRIPT_DIR"

cd "$(dirname "$0")"
BOX_PATH="${1}" VM_NAME="${2}" vagrant up
