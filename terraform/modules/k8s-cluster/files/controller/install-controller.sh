#!/bin/bash
set -euxo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "*** setting up the control plane ***"

source "${SCRIPT_DIR}/../_functions.sh"

echo "==> set SELinux to permissive mode so that we can copy files to system directories"
ssh "$CONTROLLER_INSTANCE" sudo setenforce 0

echo "==> copy all certs to etc/etcd"
ssh "$CONTROLLER_INSTANCE" "sudo mkdir -p /var/lib/kubernetes"
copy_to_remote "$CONTROLLER_INSTANCE" "/tmp/k8s-hard-way/certs/kubernetes.pem" "/var/lib/kubernetes/kubernetes.pem"
copy_to_remote "$CONTROLLER_INSTANCE" "/tmp/k8s-hard-way/certs/kubernetes-key.pem" "/var/lib/kubernetes/kubernetes-key.pem"

ssh "$CONTROLLER_INSTANCE" sudo rpm -qa | grep kube
ssh "$CONTROLLER_INSTANCE" sudo curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-apiserver
ssh "$CONTROLLER_INSTANCE" sudo curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-controller-manager
ssh "$CONTROLLER_INSTANCE" sudo curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-scheduler
ssh "$CONTROLLER_INSTANCE" sudo curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl
ssh "$CONTROLLER_INSTANCE" "find . -name 'kube*' -exec sudo chmod +x {} \;"
ssh "$CONTROLLER_INSTANCE" sudo "ls -lhart"
ssh "$CONTROLLER_INSTANCE" sudo mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/bin/

echo "<== done!"