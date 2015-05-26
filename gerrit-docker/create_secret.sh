#!/usr/bin/env bash

cat <<EOF | osc create -f -
---
  apiVersion: "v1beta3"
  kind: "Secret"
  metadata:
    name: "ssh-keys"
  data:
    "id-rsa": "$(cat ssh-keys/secret_fabric8_rsa_base64)"
    "id-rsa.pub": "$(cat ssh-keys/secret_fabric8_rsa_pub_base64)"
EOF