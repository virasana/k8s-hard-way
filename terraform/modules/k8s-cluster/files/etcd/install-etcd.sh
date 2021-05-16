#!/bin/bash
set -euxo pipefail

function copy_to_remote {
  local etcd_instance=$1
  local source_path=$2
  local remote_dest_path=$3

  local remote_tmp_path="/home/fedora${source_path}"
  local remote_tmp_dir="$(dirname "${remote_tmp_path}")"

  echo "==> copying from ${source_path} to ${etcd_instance}:${remote_dest_path}"

  echo "==> etcd_instance: ${etcd_instance}"
  echo "==> source_path: ${source_path}"
  echo "==> dest_path: ${remote_dest_path}"

  ssh "${ETCD_INSTANCE}" mkdir -p "${remote_tmp_dir}"
  ssh "${ETCD_INSTANCE}" sudo chown fedora "${remote_tmp_dir}"
  scp "${source_path}" "${etcd_instance}":"${remote_tmp_path}"
  ssh "${ETCD_INSTANCE}" sudo mv "${remote_tmp_path}" "${remote_dest_path}"

  echo "==> done!"
}

echo '*** install etcd'
echo "ETCD_INSTANCE: $ETCD_INSTANCE"
ssh "$ETCD_INSTANCE" sudo rpm -q etcd
TMP_ROOT="/tmp/k8s-hard-way"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "==> copy all certs to etc/etcd"
copy_to_remote "${ETCD_INSTANCE}" "/tmp/k8s-hard-way/certs/ca.pem" "/etc/etcd/ca.pem"
copy_to_remote "${ETCD_INSTANCE}" "/tmp/k8s-hard-way/certs/ca-key.pem" "/etc/etcd/ca-key.pem"
copy_to_remote "${ETCD_INSTANCE}" "/tmp/k8s-hard-way/certs/kubernetes.pem" "/etc/etcd/kubernetes.pem"
copy_to_remote "${ETCD_INSTANCE}" "/tmp/k8s-hard-way/certs/kubernetes-key.pem" "/etc/etcd/kubernetes-key.pem"

echo "==> copy etcd.service /etc/systemd/system/etcd.service"
copy_to_remote "${ETCD_INSTANCE}" "${TMP_ROOT}/etcd/${ETCD_INSTANCE}/etcd.service" "/etc/systemd/system/etcd.service"

echo '==> start etcd on etcd'
ssh "$ETCD_INSTANCE" sudo systemctl daemon-reload
ssh "$ETCD_INSTANCE" sudo systemctl daemon-reexec

echo "==> set SELinux to permissive mode otherwise you won't be able to enable the service"
ssh "$ETCD_INSTANCE" sudo setenforce 0
ssh "$ETCD_INSTANCE" sudo systemctl enable etcd
ssh "$ETCD_INSTANCE" sudo systemctl start etcd

echo "==> allow etcd to settle down before we check status"
sleep 30
ssh "$ETCD_INSTANCE" sudo systemctl status etcd --no-pager
echo "expected result: the above should be active without any errors"
echo "<== done"