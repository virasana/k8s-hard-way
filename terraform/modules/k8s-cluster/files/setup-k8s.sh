#!/bin/bash
set -eo pipefail

function _help() {
  echo "setup kubernetes cluster"

  echo "usage"
  printf '%-50s%s' '-h, --help' 'show help' && printf '\n'
}

function _get_opts() {
  while getopts ":h" option; do
    case $option in
    h) # display help
      _help
      exit
      ;;
    esac
  done
}

function _deploy_client_certs() {
  echo "====> copying local pem files to all instances in the kubernetes cluster"
  set -x
  scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa ca.pem kubernetes-key.pem kubernetes.pem fedora@etcd1:~/
  scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa ca.pem kubernetes-key.pem kubernetes.pem fedora@etcd2:~/
  scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa ca.pem kubernetes-key.pem kubernetes.pem fedora@controller1:~/
  scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa ca.pem kubernetes-key.pem kubernetes.pem fedora@controller2:~/
  scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa ca.pem kubernetes-key.pem kubernetes.pem fedora@worker1:~/
  scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa ca.pem kubernetes-key.pem kubernetes.pem fedora@worker2:~/
  set +x
}

function _deploy_files() {
  set -x
  echo '==> deploy files for etcd1'
  scp /tmp/etcd.service fedora@etcd1:/home/fedora/etcd.service
  scp "${SCRIPT_DIR}/etcd/install-etcd.sh" fedora@etcd1:/home/fedora/

  echo '==> deploy files for etcd2'
  scp /tmp/etcd.service fedora@etcd2:/home/fedora/etcd.service
  scp "${SCRIPT_DIR}/etcd/install-etcd.sh" fedora@etcd2:/home/fedora/
  set +x
}

function _install_etcd {
  ssh fedora@etcd1 /home/fedora/install-etcd.sh
  ssh fedora@etcd2 /home/fedora/install-etcd.sh
}

function _verify_etcd {
  ssh fedora@etcd1 sudo etcdctl --ca-file=/etc/etcd/ca.pem cluster-health
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

echo '===> setting up k8s cluster'
_get_opts
_deploy_client_certs
_deploy_files
_install_etcd
sleep 10
_verify_etcd

