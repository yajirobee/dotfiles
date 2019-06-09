#! /bin/bash -x

SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

if [[ $# -lt 1 ]]; then
    echo "USAGE: $0 (depend|init)"
    exit
fi

ACTION=$1

${SCRIPT_DIR}/init/${ACTION}_${OSTYPE}.sh
