#!/bin/bash
set -eo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

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

function _generate_certs {
  echo "*** generate kubernetes certs ***"
  echo "K8S_EIP: ${K8s_EIP}"

  "${SCRIPT_DIR}/certs/generate-certs.sh" "${K8S_EIP}"

  echo "<== done"
}

function _install_etcd {
  ETCD_INSTANCE=etcd1 "${SCRIPT_DIR}/etcd/install-etcd.sh"
  ETCD_INSTANCE=etcd2 "${SCRIPT_DIR}/etcd/install-etcd.sh"
}

function _install_controller {
  CONTROLLER_INSTANCE=controller1 "${SCRIPT_DIR}/controller/install-controller.sh"
  CONTROLLER_INSTANCE=controller2 "${SCRIPT_DIR}/controller/install-controller.sh"
}

function _ssh_config_create {
  "${SCRIPT_DIR}/utils/ssh-config-create.sh"
}

function _ssh_add_known_hosts {
  "${SCRIPT_DIR}/utils/ssh-add-known-hosts.sh"
}

function _hush_logins {
  "${SCRIPT_DIR}/utils/hush-logins.sh"
}

function _install_authentication {
  "${SCRIPT_DIR}/auth/install-authentication.sh"
}

function _install_authorisation {
  "${SCRIPT_DIR}/auth/install-authorisation.sh"
}

function _install_authorisation {
  "${SCRIPT_DIR}/encryption/encryption.sh"
}

echo '===> setting up k8s cluster'
_get_opts
_generate_certs
_ssh_config_create
_ssh_add_known_hosts
_hush_logins
_install_authentication
_generate_encyption
#_install_authorisation
#_install_etcd
#_install_controller