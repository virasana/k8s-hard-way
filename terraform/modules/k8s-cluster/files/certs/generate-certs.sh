echo "***** Generate Certs *****"
echo "usage: \./generate-certs/sh <EIP Address>"
SCRIPT_DIR=$(dirname $(readlink -f "$0"))
CA_PEM_FILE_PATH="./ca.pem"
KUBERNETES_PUBLIC_IP_ADDRESS=$1

if [ -f "$CA_PEM_FILE_PATH" ]; then
  echo "${CA_PEM_FILE_PATH} file already exists so skipping cert creation."
else
  echo "==> no .pem file found in '${CA_PEM_FILE_PATH}' so I am generating new certs"
  echo "==> generating a new ca cert"
  cfssl gencert -initca "/tmp/ca-csr.json" | cfssljson -bare ca
  echo "==> here is the new ca cert:"
  openssl x509 g-in $CA_PEM_FILE_PATH -text -noout

  echo "==> generating a new kubernetes tls cert"
  (
    set -x
    KUBERNETES_PUBLIC_IP_ADDRESS=$1
    cfssl gencert -ca=ca.pem \
      -ca-key=ca-key.pem \
      -config="${SCRIPT_DIR}/ca-config.json" \
      -profile=kubernetes /tmp/kubernetes-csr.json | cfssljson -bare kubernetes
  )
fi

echo "===> displaying output of cert generation process"
echo $PWD
find ./ -type f \( -iname \*.pem -o -iname \*.csr \)

echo "<=== generate-certs.sh --> done!"

