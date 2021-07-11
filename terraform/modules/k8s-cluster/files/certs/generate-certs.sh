#!/bin/bash
set -euo pipefail

echo "***** Generate Certs *****"
echo "usage: \./generate-certs/sh <EIP Address>"

KUBERNETES_PUBLIC_IP_ADDRESS=$1
TMP_ROOT="/tmp/k8s-hard-way"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
CA_PEM_FILE_PATH="${TMP_ROOT}/certs/ca.pem"
CA_KEY_FILE_PATH="${TMP_ROOT}/certs/ca-key.pem"
CA_CSR_PATH="${TMP_ROOT}/certs/ca-csr.json"
CA_CONFIG_PATH="${SCRIPT_DIR}/ca-config.json"
K8S_PEM_FILE_PATH="${TMP_ROOT}/certs/kubernetes.pem"
K8S_KEY_FILE_PATH="${TMP_ROOT}/certs/kubernetes-key.pem"
K8S_CSR_PATH="${TMP_ROOT}/certs/kubernetes-csr.json"

echo "KUBERNETES_PUBLIC_IP_ADDRESS: ${KUBERNETES_PUBLIC_IP_ADDRESS}"
echo "TMP_ROOT=${TMP_ROOT}"
echo "CA_PEM_FILE_PATH=${CA_PEM_FILE_PATH}"
echo "CA_KEY_FILE_PATH=${CA_KEY_FILE_PATH}"
echo "CA_CSR_PATH=${CA_CSR_PATH}"
echo "CA_CONFIG_PATH=${CA_CONFIG_PATH}"
echo "K8S_PEM_FILE_PATH=${K8S_PEM_FILE_PATH}"
echo "K8S_KEY_FILE_PATH=${K8S_KEY_FILE_PATH}"
echo "K8S_CSR_PATH=${K8S_CSR_PATH}"
echo

if [ -f "$CA_PEM_FILE_PATH" ]; then
  echo "${CA_PEM_FILE_PATH} file already exists so skipping cert creation."
else
  echo "==> no .pem file found in '${CA_PEM_FILE_PATH}' so I am generating new certs"
  echo "==> generating a new ca cert"
  cfssl gencert -initca "${CA_CSR_PATH}" | cfssljson -bare ca
  mv ca.pem "${CA_PEM_FILE_PATH}"
  mv ca-key.pem "${CA_KEY_FILE_PATH}"
  echo "==> here is the new ca cert:"
  openssl x509 -in $CA_PEM_FILE_PATH -text -noout

  echo "==> generating a new kubernetes tls cert"
  KUBERNETES_PUBLIC_IP_ADDRESS=$1
  cfssl gencert -ca="${CA_PEM_FILE_PATH}" \
    -ca-key="${CA_KEY_FILE_PATH}" \
    -config="${CA_CONFIG_PATH}" \
    -profile=kubernetes "${K8S_CSR_PATH}" | cfssljson -bare kubernetes
  mv kubernetes.pem "${K8S_PEM_FILE_PATH}"
  mv kubernetes-key.pem "${K8S_KEY_FILE_PATH}"
fi

echo "===> displaying output of cert generation process"
find "${TMP_ROOT}/certs/" | grep '.pem'
echo "<=== generate-certs.sh --> done!"