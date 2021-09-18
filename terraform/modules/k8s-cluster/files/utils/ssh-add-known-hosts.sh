#!/bin/bash
echo "*** ADD KNOWN HOSTS ***"
echo "==> prerequisite - you must run ssh-config-create.sh before running this script"
for instance in "worker0.ksone" "worker1.ksone" "worker2.ksone" "controller0.ksone" "controller1.ksone" "controller2.ksone"
do
  ssh-keygen -R $instance
  ssh $instance sudo hostname
done
echo "<== done!"
