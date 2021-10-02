#!/bin/bash
set -euxo pipefail

export AWS_DEFAULT_REGION='eu-west-1'

echo '*** INSTALL ETCD ***'

function _download_binaries() {
  echo "*** DOWNLOAD BINARIES ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance}"
    ssh "${instance}" wget -q --https-only --timestamping \
      "https://github.com/etcd-io/etcd/releases/download/v3.4.15/etcd-v3.4.15-linux-amd64.tar.gz"
  done
  echo "<== done!"
}

function _extract_and_install() {
  echo "*** EXTRACT AND INSTALL ETCD BINARIES ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance}"
    ssh "${instance}" tar -xf etcd-v3.4.15-linux-amd64.tar.gz
    ssh "${instance}" sudo mv etcd-v3.4.15-linux-amd64/etcd* /usr/local/bin/
  done
  echo "<== done!"
}

function _configure_etcd_server() {
  echo "** CONFIGURE ETCD SERVER ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    echo "${instance}"
    ssh "${instance}" sudo mkdir -p /etc/etcd /var/lib/etcd
    ssh "${instance}" sudo chmod 700 /var/lib/etcd
    ssh "${instance}" sudo cp ca.pem kubernetes-key.pem kubernetes.pem /etc/etcd/
    controller_name=$(echo "${instance}" | sed 's/.ksone//g')
    internal_ip=$(aws --region=eu-west-1 ec2 describe-instances | jq --arg instance_name "${controller_name}" -r '.Reservations[].Instances[] | select(.Tags[] | select(.Key=="Description" and .Value==$instance_name)).NetworkInterfaces[].PrivateIpAddress')
    echo "==> create the etcd.service file"
    mkdir -p "/tmp/k8s-hard-way/etcd/"
    cat <<EOF | tee "/tmp/k8s-hard-way/etcd/${instance}-etcd.service"
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
Type=notify
ExecStart=/usr/local/bin/etcd \\
  --name ${controller_name} \\
  --cert-file=/etc/etcd/kubernetes.pem \\
  --key-file=/etc/etcd/kubernetes-key.pem \\
  --peer-cert-file=/etc/etcd/kubernetes.pem \\
  --peer-key-file=/etc/etcd/kubernetes-key.pem \\
  --trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-trusted-ca-file=/etc/etcd/ca.pem \\
  --peer-client-cert-auth \\
  --client-cert-auth \\
  --initial-advertise-peer-urls https://${internal_ip}:2380 \\
  --listen-peer-urls https://${internal_ip}:2380 \\
  --listen-client-urls https://${internal_ip}:2379,https://127.0.0.1:2379 \\
  --advertise-client-urls https://${internal_ip}:2379 \\
  --initial-cluster-token etcd-cluster-0 \\
  --initial-cluster controller0=https://10.240.0.10:2380,controller1=https://10.240.0.11:2380,controller2=https://10.240.0.12:2380 \\
  --initial-cluster-state new \\
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    scp "/tmp/k8s-hard-way/etcd/${instance}-etcd.service" ${instance}:/home/ubuntu/${instance}-etcd.service
    ssh "${instance}" sudo mv /home/ubuntu/${instance}-etcd.service /etc/systemd/system/etcd.service
  done
  echo "<== done!"
}

function _start_etcd_server() {
  echo "*** START ETCD SERVER ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    (
      ssh "${instance}" sudo systemctl daemon-reload
      ssh "${instance}" sudo systemctl enable etcd
      echo "==> start etcd on ${instance}.  Using shell background process so that we can move on"
      ssh "${instance}" sudo systemctl start etcd &
    )
  done
  echo "<== done!"
}

function _verify_etcd_servers() {
  echo "*** VERIFY ETCD SERVERS ***"
  for instance in "controller0.ksone" "controller1.ksone" "controller2.ksone"; do
    ssh "${instance}" 'sudo ETCDCTL_API=3 etcdctl member list \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/etcd/ca.pem \
    --cert=/etc/etcd/kubernetes.pem \
    --key=/etc/etcd/kubernetes-key.pem'
  done
  echo "<== done!"
}

_download_binaries
_extract_and_install
_configure_etcd_server
_start_etcd_server
_verify_etcd_servers
