#!/bin/bash

set -eo pipefail;

function _help {
  echo "setup kubernetes cluster"

  echo "usage"
  printf '%-50s%s' '-h, --help' 'show help' && printf '\n'
}

function _get_opts {
  while getopts ":h" option; do
     case $option in
        h) # display help
           _help
           exit
     esac
  done
}

function _install_etcd {
  echo '===> install etcd'
  echo $(ssh fedora@etcd1 sudo rpm -q etcd)
  echo '<== done'

  echo '===> move /home/fedora/*.pemfiles -->  /etc/etcd'
  echo $(if [ -f '*.pem' ]; then ssh fedora@etcd1 sudo mv  /home/fedora/*.pem /etc/etcd/; else echo 'nothing to move (possibly already done in a previous run of this script?) skipping...'; fi)
  echo '<== done'

  echo '====> move service file'
  (set +x; scp /tmp/etcd.service fedora@etcd1:/home/fedora/etcd.service)
  ssh fedora@etcd1 sudo mv /home/fedora/etcd.service /etc/systemd/system/
  echo '<=== done'
}

echo '===> setting up k8s cluster'
_get_opts
_install_etcd
