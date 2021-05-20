#!/bin/bash

scp fedora@etcd1 
echo "===> install etcd"
rpm -q etcd

echo "===> moving cert files to etc/etcd"
sudo mv  /home/fedora/*.pem /etc/etcd/

echo "===> create etcd service systemd unit"
cat > etcd.service <<"EOF"
[Unit]
Description=etcd
Documentation=https://github.com/coreos

[Service]
ExecStart=/usr/bin/etcd --name ETCD_NAME \
  --cert-file=/etc/etcd/kubernetes.pem \
  --key-file=/etc/etcd/kubernetes-key.pem \
  --peer-cert-file=/etc/etcd/kubernetes.pem \
  --peer-key-file=/etc/etcd/kubernetes-key.pem \
  --trusted-ca-file=/etc/etcd/ca.pem \
  --peer-trusted-ca-file=/etc/etcd/ca.pem \
  --initial-advertise-peer-urls https://INTERNAL_IP:2380 \
  --listen-peer-urls https://INTERNAL_IP:2380 \
  --listen-client-urls https://INTERNAL_IP:2379,http://127.0.0.1:2379 \
  --advertise-client-urls https://INTERNAL_IP:2379 \
  --initial-cluster-token etcd-cluster-0 \
  --initial-cluster etcd1=https://10.0.0.245:2380,etcd2=https://10.0.0.246:2380 \
  --initial-cluster-state new \
  --data-dir=/var/lib/etcd
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF 

echo "set environment variables"
INTERNAL_IP=10.0.0.245
ETCD_NAME=etcd1

echo "===> INTERNAL_IP=${INTERNAL_IP}" 
echo "===> ETCD_NAME=${ETCD_NAME}"

echo "===> configure the etcd service"
sed -i s/INTERNAL_IP/$INTERNAL_IP/g etcd.service
sed -i s/ETCD_NAME/$ETCD_NAME/g etcd.service
sudo mv etcd.service /etc/systemd/system/

echo "===> start etcd on this node"
sudo systemctl daemon-reload
sudo systemctl enable etcd
sudo systemctl start etcd

echo "verify etcd service"
sudo systemctl status etcd --no-pager

echo "check system health - should be unhealthy at this point"
sudo etcdctl --ca-file=/etc/etcd/ca.pem cluster-health
