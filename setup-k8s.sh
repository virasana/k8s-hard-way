#!/bin/bash

script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
ln -s /tmp/files Â$script_dirterraform/modules/k8s-cluster/files/

echo "==> setting up kubernetes"

echo "==> terraform apply - set up the aws infrastructure"
pushd ./terraform/config/dev
terraform apply -auto-approve
popd

pushd ./ansible
echo "ansible-playbook - setup kubernetes on the aws instances"
cp ./hosts /etc/ansible/
popd



