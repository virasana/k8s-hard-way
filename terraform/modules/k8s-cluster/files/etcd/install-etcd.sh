#!/bin/bash

set -exo pipefail

echo '==> install etcd'
sudo rpm -q etcd
echo '<== done'

echo '==> move /home/fedora/*.pem files -->  /etc/etcd'
if [ -f '/home/fedora/kubernetes-key.pem' ]; then
  sudo mv -v /home/fedora/*.pem /etc/etcd/
  else
  echo 'nothing to move (possibly already done in a previous run of this script?) skipping...'
fi
echo '<== done'

echo '==> move service file'
sudo mv -v /home/fedora/etcd.service /etc/systemd/system/
echo '<== done'

echo '==> start etcd on etcd'
sudo systemctl daemon-reload
sudo systemctl daemon-reexec
echo "set SELinux to permissive mode otherwise you won't be able to enable the service"
sudo setenforce 0
sudo systemctl enable etcd
sudo systemctl start etcd
sudo systemctl status etcd --no-pager
echo "expected result: the above should read 'listening for client requests'"
echo "<== done"