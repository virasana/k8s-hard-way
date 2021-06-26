#!/bin/bash

echo "==> setting up kubernetes"

echo "==> terraform apply - set up the aws infrastructure"
terraform apply -auto-approve

echo ""ansible-playbook - setup kubernetes on the aws instances"
cp ./ansible/hosts /etc/ansible/

