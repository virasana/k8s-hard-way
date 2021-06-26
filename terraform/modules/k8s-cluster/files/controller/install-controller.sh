#!/bin/bash
echo "setting up the control plane"

echo "mkdir -p /var/lib/kubernetes"
mkdir -p /var/lib/kubernetes
mv ca.pem kubernetes-key.pem kubernetes.pem /var/lib/kubernetes/
rpm -qa | grep kube
curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-apiserver
curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-controller-manager
curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kube-scheduler
curl -s -O https://storage.googleapis.com/kubernetes-release/release/v1.3.0/bin/linux/amd64/kubectl
chmod +x kube*
mv kube-apiserver kube-controller-manager kube-scheduler kubectl /usr/bin/
echo "<== done!"