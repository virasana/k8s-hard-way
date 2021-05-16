#!/bin/bash

echo "** delete etcd d from all nodes **"
read -rp "WARNING!  This will delete the etcd data dir and reset etcd.  Type 'yes' to continue?> " the_reply

if [ $the_reply == "yes" ]
then
  (
  set -x
  ssh etcd1 sudo rm -rf /var/lib/etcd/*
  ssh etcd2 sudo rm -rf /var/lib/etcd/*
  echo "<== done"
  )
fi

