#!/bin/bash

echo "install curl"
apt-update
apt-get install -y curl

     --url 'http://example.com'\
     --output './path/to/file'

echo "setup hosts file"
cat <<EOT >> /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
${network_ip_etcd_1}	etcd1
${network_ip_etcd_2}	etcd2
${network_ip_controller_1}	controller1
${network_ip_controller_2}	controller2
${network_ip_worker_1}	worker1
${network_ip_worker_2}	worker2
EOT
