#!/bin/bash
TMP_ROOT="/tmp/k8s-hard-way"
KUBERNETES_PUBLIC_ADDRESS=$(aws ec2 describe-addresses | jq -r '. | select(.Addresses[].Tags[] | .Key=="name" and .Value=="k8s-hard-way").Addresses[].PublicIp')

function _create_kubeconfig_for_workers {
  echo "*** CREATE KUBECONFIG FOR WORKERS ***"
  for instance in "worker0.ksone" "worker1.ksone" "worker2.ksone"; do
    kubectl config set-cluster kubernetes-the-hard-way \
      --certificate-authority="${TMP_ROOT}/certs/ca.pem" \
      --embed-certs=true \
      --server="https://${KUBERNETES_PUBLIC_ADDRESS}:6443" \
      --kubeconfig="${instance}.kubeconfig"

    kubectl config set-credentials system:node:${instance} \
      --client-certificate="${TMP_ROOT}/certs/${instance}.pem" \
      --client-key="${TMP_ROOT}/certs/${instance}-key.pem" \
      --embed-certs=true \
      --kubeconfig="${instance}.kubeconfig"

    kubectl config set-context default \
      --cluster=kubernetes-the-hard-way \
      --user=system:node:${instance} \
      --kubeconfig=${instance}.kubeconfig

    kubectl config use-context default --kubeconfig=${instance}.kubeconfig
  done
  echo "<== done!"
}

function _create_kubeconfig_for_kube_proxy {
  echo "*** CREATE KUBECONFIG FOR KUBE PROXY ***"
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority="${TMP_ROOT}/certs/ca.pem" \
    --embed-certs=true \
    --server="https://${KUBERNETES_PUBLIC_ADDRESS}:6443" \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-credentials system:kube-proxy \
    --client-certificate="${TMP_ROOT}/certs/kube-proxy.pem" \
    --client-key="${TMP_ROOT}/certs/kube-proxy-key.pem" \
    --embed-certs=true \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-proxy \
    --kubeconfig=kube-proxy.kubeconfig

  kubectl config use-context default --kubeconfig=kube-proxy.kubeconfig
  echo "<== done!"
}

function _create_kubeconfig_for_controller_manager {
  echo "*** CREATE KUBECONFIG FOR CONTROLLER MANAGER ***"
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority="${TMP_ROOT}/certs/ca.pem" \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-credentials system:kube-controller-manager \
    --client-certificate="${TMP_ROOT}/certs/kube-controller-manager.pem" \
    --client-key="${TMP_ROOT}/certs/kube-controller-manager-key.pem" \
    --embed-certs=true \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-controller-manager \
    --kubeconfig=kube-controller-manager.kubeconfig

  kubectl config use-context default --kubeconfig=kube-controller-manager.kubeconfig
  echo "<== done!"
}

function _create_kubeconfig_for_kube_scheduler {
  echo "*** CREATE KUBECONFIG FOR KUBE SCHEDULER ***"
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority="${TMP_ROOT}/certs/ca.pem" \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-credentials system:kube-scheduler \
    --client-certificate="${TMP_ROOT}/certs/kube-scheduler.pem" \
    --client-key=kube-scheduler-key.pem \
    --embed-certs=true \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=system:kube-scheduler \
    --kubeconfig=kube-scheduler.kubeconfig

  kubectl config use-context default --kubeconfig=kube-scheduler.kubeconfig
  echo "<== done!"
}

function _create_kubeconfig_for_admin_user {
  echo "*** CREATE KUBECONFIG FILE FOR ADMIN USER ***"
  kubectl config set-cluster kubernetes-the-hard-way \
    --certificate-authority="${TMP_ROOT}/certs/ca.pem" \
    --embed-certs=true \
    --server=https://127.0.0.1:6443 \
    --kubeconfig=admin.kubeconfig

  kubectl config set-credentials admin \
    --client-certificate="${TMP_ROOT}/certs/admin.pem" \
    --client-key="${TMP_ROOT}/certs/admin-key.pem" \
    --embed-certs=true \
    --kubeconfig=admin.kubeconfig

  kubectl config set-context default \
    --cluster=kubernetes-the-hard-way \
    --user=admin \
    --kubeconfig=admin.kubeconfig

  kubectl config use-context default --kubeconfig=admin.kubeconfig
  echo "<== done!"
}

function _distribute_kubeconfig_files {
  echo "*** DISTRIBUTE KUBECONFIG FILES ***"
  for instance in "worker0.ksone" "worker1.ksone" "worker2.ksone"; do
    echo "==> ${instance}"
    scp "${instance}.kubeconfig" "kube-proxy.kubeconfig" ${instance}:~/
  done

  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "==> ${instance}"
    scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig ${instance}:~/
  done
  echo "<== done!"
}

echo "==> INSTALLING K8S AUTHENTICATION (local kubeconfig)**"


echo "KUBERNETES_PUBLIC_ADDRESS ${KUBERNETES_PUBLIC_ADDRESS}"
_create_kubeconfig_for_workers
_create_kubeconfig_for_kube_proxy
_create_kubeconfig_for_controller_manager
_create_kubeconfig_for_kube_scheduler
_create_kubeconfig_for_admin_user
_distribute_kubeconfig_files