#!/bin/bash

echo "install curl"
apt-update
apt-get install -y curl

echo "===> delete previous hosts file entries"
awk '!/etcd|worker|controller/' /etc/hosts > /tmp/hosts-tmp
cat /tmp/hosts-tmp > /etc/hosts
rm -f /tmp/hosts-tmp
echo "<=== done!"

echo "===> setup hosts file"
cat <<EOT >> /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
${network_ip_etcd_1}	etcd1
${network_ip_etcd_2}	etcd2
${network_ip_controller_1}	controller1
${network_ip_controller_2}	controller2
${network_ip_worker_1}	worker1
${network_ip_worker_2}	worker2
EOT
echo "<=== done!"