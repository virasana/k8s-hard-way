#!/bin/bash
set -eo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

function _generate_certs {
  echo "*** generate kubernetes certs ***"
  echo "K8S_EIP: ${K8s_EIP}"

  "${SCRIPT_DIR}/certs/generate-certs.sh" "${K8S_EIP}"

  echo "<== done"
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

function _generate_encyption {
  "${SCRIPT_DIR}/encryption/encryption.sh"
}

function _install_etcd {
  "${SCRIPT_DIR}/etcd/install-etcd.sh"
}

function _bootstrap_control_plane {
  "${SCRIPT_DIR}/control-plane/bootstrap-control-plane.sh"
}

echo '===> setting up k8s cluster'
#_ssh_config_create
#_ssh_add_known_hosts
#_hush_logins
#_generate_certs
#_install_authentication
#_generate_encyption
#_install_etcd
_bootstrap_control_plane
