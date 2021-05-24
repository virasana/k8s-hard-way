#!/bin/bash

set -exo pipefail

echo '==> install etcd'
sudo rpm -q etcd
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