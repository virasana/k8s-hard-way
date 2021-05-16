#!/bin/bash

echo "***HUSH INSTANCE LOGINS ***"
for i in {0..2}
do
  for instance_type in worker controller
  do
    instance_name="${instance_type}${i}.ksone"
    echo "==> copying .hushlogin to instance ${instance_name}"
    ssh $instance_name touch /home/ubuntu/.hushlogin
  done
done
