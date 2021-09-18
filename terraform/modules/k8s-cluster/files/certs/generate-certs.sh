#!/bin/bash
set -euo pipefail

echo "***** Generate Certs *****"
echo "usage: \./generate-certs/sh <EIP Address>"

KUBERNETES_PUBLIC_ADDRESS=$(aws ec2 describe-addresses | jq -r '. | select(.Addresses[].Tags[] | .Key=="name" and .Value=="k8s-hard-way").Addresses[].PublicIp')
TMP_ROOT="/tmp/k8s-hard-way/certs"

function _create_ca_cert {
  echo "*** CREATE CA CERT ***"
  {
    cat > "${TMP_ROOT}/ca-config.json" <<EOF
    {
      "signing": {
        "default": {
          "expiry": "8760h"
        },
        "profiles": {
          "kubernetes": {
            "usages": ["signing", "key encipherment", "server auth", "client auth"],
            "expiry": "8760h"
          }
        }
      }
    }
EOF

    cat > "${TMP_ROOT}/ca-csr.json" <<EOF
    {
      "CN": "Kubernetes",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "London",
          "O": "Kubernetes",
          "OU": "CA",
          "ST": "Devon"
        }
      ]
    }
EOF
    cfssl gencert -initca "${TMP_ROOT}/ca-csr.json" | cfssljson -bare ca
  }
}

function _create_admin_cert {
  echo "*** CREATE ADMIN CERT ***"
  {
    cat > admin-csr.json <<EOF
    {
      "CN": "admin",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "London",
          "O": "system:masters",
          "OU": "Kubernetes The Hard Way",
          "ST": "Devon"
        }
      ]
    }
EOF
    (
      set -x;
      cfssl gencert \
        -ca="${TMP_ROOT}/ca.pem" \
        -ca-key="${TMP_ROOT}/ca-key.pem" \
        -config="${TMP_ROOT}/ca-config.json" \
        -profile=kubernetes \
        admin-csr.json | cfssljson -bare admin
      set +x;
    )
  }
}

function _create_kubelet_certs {
  echo "*** CREATE KUBELET CERTS ***"
  for instance in "worker0.ksone" "worker1.ksone" "worker2.ksone"; do
    cat > ${instance}-csr.json <<EOF
    {
      "CN": "system:node:${instance}",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "London",
          "O": "system:nodes",
          "OU": "Kubernetes The Hard Way",
          "ST": "Devon"
        }
      ]
    }
EOF

    external_ip=$(aws ec2 describe-instances | jq --arg instance_name $instance -r '.Reservations[].Instances[] | select(.Tags[] | select(.Key=="Description" and .Value==$instance_name)).NetworkInterfaces[].PublicIpAddress')
    internal_ip=$(aws ec2 describe-instances | jq --arg instance_name $instance -r '.Reservations[].Instances[] | select(.Tags[] | select(.Key=="Description" and .Value==$instance_name)).NetworkInterfaces[].PrivateIpAddress')

    cfssl gencert \
      -ca="${TMP_ROOT}/ca.pem" \
      -ca-key="${TMP_ROOT}/ca-key.pem" \
      -config="${TMP_ROOT}/ca-config.json" \
      -hostname="${instance}","${external_ip}","${internal_ip}" \
      -profile=kubernetes \
      ${instance}-csr.json | cfssljson -bare ${instance}
  done
}

function _create_controller_manager_client_cert {
  echo "*** CREATE CONTROLLER MANAGER CLIENT CERT ***"
  {
    cat > kube-controller-manager-csr.json <<EOF
    {
      "CN": "system:kube-controller-manager",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "London",
          "O": "system:kube-controller-manager",
          "OU": "Kubernetes The Hard Way",
          "ST": "Devon"
        }
      ]
    }
EOF
    cfssl gencert \
      -ca="${TMP_ROOT}/ca.pem" \
      -ca-key="${TMP_ROOT}/ca-key.pem" \
      -config="${TMP_ROOT}/ca-config.json" \
      -profile=kubernetes \
      kube-controller-manager-csr.json | cfssljson -bare kube-controller-manager
    }
}

function _create_kube_proxy_client_cert {
    echo "*** CREATE KUBE PROXY CLIENT CERT ***"
  {
    cat > kube-proxy-csr.json <<EOF
    {
      "CN": "system:kube-proxy",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "London",
          "O": "system:node-proxier",
          "OU": "Kubernetes The Hard Way",
          "ST": "Devon"
        }
      ]
    }
EOF

    cfssl gencert \
      -ca="${TMP_ROOT}/ca.pem" \
      -ca-key="${TMP_ROOT}/ca-key.pem" \
      -config="${TMP_ROOT}/ca-config.json" \
      -profile=kubernetes \
      kube-proxy-csr.json | cfssljson -bare kube-proxy
    }
}

function _create_scheduler_client_cert {
  echo "*** CREATE SCHEDULER CLIENT CERT ***"
  {
    cat > kube-scheduler-csr.json <<EOF
    {
      "CN": "system:kube-scheduler",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "London",
          "O": "system:kube-scheduler",
          "OU": "Kubernetes The Hard Way",
          "ST": "Devon"
        }
      ]
    }
EOF

    cfssl gencert \
      -ca="${TMP_ROOT}/ca.pem" \
      -ca-key="${TMP_ROOT}/ca-key.pem" \
      -config="${TMP_ROOT}/ca-config.json" \
      -profile=kubernetes \
      kube-scheduler-csr.json | cfssljson -bare kube-scheduler
    }
}

function _create_k8s_api_cert {
  echo "*** CREATE K8S API CERT ***"
  {
    KUBERNETES_HOSTNAMES=kubernetes,kubernetes.default,kubernetes.default.svc,kubernetes.default.svc.cluster,kubernetes.svc.cluster.local

    cat > kubernetes-csr.json <<EOF
    {
      "CN": "kubernetes",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "London",
          "O": "Kubernetes",
          "OU": "Kubernetes The Hard Way",
          "ST": "Devon"
        }
      ]
    }
EOF

    cfssl gencert \
      -ca="${TMP_ROOT}/ca.pem" \
      -ca-key="${TMP_ROOT}/ca-key.pem" \
      -config="${TMP_ROOT}/ca-config.json" \
      -hostname=10.32.0.1,10.240.0.10,10.240.0.11,10.240.0.12,${KUBERNETES_PUBLIC_ADDRESS},127.0.0.1,${KUBERNETES_HOSTNAMES} \
      -profile=kubernetes \
      kubernetes-csr.json | cfssljson -bare kubernetes
    }
}

function _create_service_account_key_pair {
  echo "*** CREATE SERVICE ACCOUNT KEY PAIR ***"
  {
    cat > service-account-csr.json <<EOF
    {
      "CN": "service-accounts",
      "key": {
        "algo": "rsa",
        "size": 2048
      },
      "names": [
        {
          "C": "GB",
          "L": "Londin",
          "O": "Kubernetes",
          "OU": "Kubernetes The Hard Way",
          "ST": "Devon"
        }
      ]
    }
EOF

    cfssl gencert \
      -ca="${TMP_ROOT}/ca.pem" \
      -ca-key="${TMP_ROOT}/ca-key.pem" \
      -config="${TMP_ROOT}/ca-config.json" \
      -profile=kubernetes \
      service-account-csr.json | cfssljson -bare service-account
    }
}

function _distribute_certs {
  echo "*** DISTRIBUTING CERTS TO INSTANCES ***"
  for instance in "worker0.ksone" "worker1.ksone" "worker2.ksone"; do
    echo "==> instance: ${instance}"
    scp "${TMP_ROOT}/ca.pem" "${TMP_ROOT}/${instance}-key.pem" "${TMP_ROOT}/${instance}.pem" "${instance}":~/
  done
  echo "<== done!"

  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "==> instance: ${instance}"
    scp "${TMP_ROOT}/ca.pem" "${TMP_ROOT}/ca-key.pem" "${TMP_ROOT}/kubernetes-key.pem" \
      "${TMP_ROOT}/kubernetes.pem" "${TMP_ROOT}/service-account-key.pem" "${TMP_ROOT}/service-account.pem" \
      "${instance}":~/
  done
  echo "<== done!"
}

[ "$(ls -A ${TMP_ROOT}/* )" ] && echo "==> [WARNING] - ${TMP_ROOT}/ is not empty - skipping certs generation.  Use rm -rf '${TMP_ROOT}' && mkdir ${TMP_ROOT} to re-create certs." && exit 0
mkdir -p "${TMP_ROOT}"
pushd "${TMP_ROOT}"
_create_ca_cert
_create_admin_cert
_create_kubelet_certs
_create_controller_manager_client_cert
_create_kube_proxy_client_cert
_create_scheduler_client_cert
_create_k8s_api_cert
_create_service_account_key_pair
_distribute_certs
popd
