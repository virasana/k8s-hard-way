#!/bin/bash
echo "==> cleaning up ssh keys to prevent 'man-ion-the-middle' errors from being raised."
ssh-keygen -f '/root/.ssh/known_hosts' -R 'controller1'
ssh-keygen -f '/root/.ssh/known_hosts' -R 'controller2'
ssh-keygen -f '/root/.ssh/known_hosts' -R 'etcd1'
ssh-keygen -f '/root/.ssh/known_hosts' -R 'etcd2'
ssh-keygen -f '/root/.ssh/known_hosts' -R 'worker1'
ssh-keygen -f '/root/.ssh/known_hosts' -R 'worker2'
echo "<== done!"