#!/bin/bash
echo "===> delete previous hosts file entries"
awk '!/etcd|worker|controller/' /etc/hosts > /tmp/hosts-tmp
cat /tmp/hosts-tmp > /etc/hosts
rm -f /tmp/hosts-tmp
echo "<=== done!"
echo "===> updating hosts file"
echo "${hosts_entries}" >> /etc/hosts
echo "<=== done!"