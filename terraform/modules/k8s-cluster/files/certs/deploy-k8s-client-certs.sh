#!/bin/bash
echo "==> copying local pem files to all instances in the kubernetes cluster"
set -x
scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa  ca.pem kubernetes-key.pem kubernetes.pem  fedora@etcd1:~/
scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa  ca.pem kubernetes-key.pem kubernetes.pem  fedora@etcd2:~/
scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa  ca.pem kubernetes-key.pem kubernetes.pem  fedora@controller1:~/
scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa  ca.pem kubernetes-key.pem kubernetes.pem  fedora@controller2:~/
scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa  ca.pem kubernetes-key.pem kubernetes.pem  fedora@worker1:~/
scp -o StrictHostKeyChecking=no -i $HOME/.ssh/id_rsa  ca.pem kubernetes-key.pem kubernetes.pem  fedora@worker2:~/
set +x