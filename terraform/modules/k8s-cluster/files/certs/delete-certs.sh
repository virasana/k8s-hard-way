#!/bin/bash
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
echo "==> deleting all .pem and .csr files from local config tree."
echo "This is a destructive operation which will delete .pem and .csr files from your shell workspace ('${SCRIPT_DIR}')."
read -p "Do you wish to continue? (Ctrl-c to escape or ENTER to continue)"
(
set -x
rm -f './ca-key.pem'
rm -f './ca.pem' 
rm -f './ca.csr'
)
ls -lhart
