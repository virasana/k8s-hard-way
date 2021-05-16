#!/bin/bash
echo "*** CREATE SSH CONFIG FILE ***"

export AWS_DEFAULT_REGION="eu-west-1"
BASTION_IP=$(echo "$(aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | select(.Tags[] | select(.Key=="Description" and .Value=="bastion-ksone")).NetworkInterfaces[].Association.PublicIp')")

echo "AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"
echo "BASTION_IP: ${BASTION_IP}"

cat > $HOME/.ssh/config <<EOF
### The Bastion Host
Host *
  StrictHostKeyChecking no
Host bastion
  HostName $BASTION_IP
  User ubuntu
### The Remote Host
Host *.ksone
  ProxyJump bastion
  User ubuntu
EOF

echo "$HOME/.ssh/config:"
cat $HOME/.ssh/config

echo "==> you can now ssh to remote instances using the following:"
echo "ssh worker0.ksone"
echo "ssh worker1.ksone"
echo "ssh worker2.ksone"
echo "ssh controller0.ksone"
echo "ssh controller1.ksone"
echo "ssh controller2.ksone"
echo "etc..."


