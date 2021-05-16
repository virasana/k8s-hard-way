#!/bin/bash

set -euo pipefail

TMP_ENCRYPTION="/tmp/encryption/"

function _generate_encryption_key {
  echo "*** GENERATE ENCRYPTION KEY ***"
  ENCRYPTION_KEY=$(head -c 32 /dev/urandom | base64)
  echo "<== done!"
}

function _generate_encryption_config_file {
  echo "*** GENERATE ENCRYPTION CONFIG FILE ***"
  mkdir -p "${TMP_ENCRYPTION}"
  cat > "${TMP_ENCRYPTION}encryption-config.yaml" <<EOF
kind: EncryptionConfig
apiVersion: v1
resources:
  - resources:
      - secrets
    providers:
      - aescbc:
          keys:
            - name: key1
              secret: ${ENCRYPTION_KEY}
      - identity: {}
EOF
  echo "<== done!"
}

function _distribute_encryption_config {
  echo "*** DISTRIBUTE ENCRYPTION CONFIG ***"
  for instance in "worker0.ksone" "worker1.ksone" "worker2.ksone" "controller0.ksone" "controller1.ksone" "controller2.ksone"
  do
    echo "==> ${instance}"
    scp /tmp/encryption/encryption-config.yaml ${instance}:~/
    ssh "${instance}" cat "~/encryption-config.yaml" | sed 's/secret:.*/secret: *****/g'
  done
  echo "<== done!"
}

_generate_encryption_key
_generate_encryption_config_file
_distribute_encryption_config

