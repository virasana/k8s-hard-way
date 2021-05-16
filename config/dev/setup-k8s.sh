#!/bin/bash
set -euxo pipefail
THE_ENVIRONMENT="dev"

function _terraform_apply {
  echo "==> terraform apply - set up the aws infrastructure"
  terraform apply -auto-approve
}

function _setup_k8s {
  echo "==> set up kubernetes on AWS instances"
  ../../terraform/modules/k8s-cluster/files/setup-k8s.sh
}

#_terraform_apply
_setup_k8s