#!/bin/bash
echo "==> installing authentication"
curl -O  https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/token.csv
sudo mv token.csv /var/lib/kubernetes/
