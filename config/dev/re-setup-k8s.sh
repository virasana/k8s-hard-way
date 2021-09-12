#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "*** COMPLETELY SETUP K8S FROM SCRATCH - WILL WIPE OUT YOUR CURRENT CONFIG***"

 rm -rf '/tmp/k8s-hard-way/certs' && mkdir /tmp/k8s-hard-way/certs
"${SCRIPT_DIR}/setup-k8s.sh"
