#!/bin/bash

echo "installing authorisation"
curl -sO  https://raw.githubusercontent.com/kelseyhightower/kubernetes-the-hard-way/master/authorization-policy.jsonl
sudo mv authorization-policy.jsonl /var/lib/kubernetes/