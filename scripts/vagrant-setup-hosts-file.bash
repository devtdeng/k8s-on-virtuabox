#!/bin/bash

set -euo pipefail

cat <<EOF | sudo tee -a /etc/hosts
192.168.199.10 master-0
192.168.199.11 master-1
192.168.199.12 master-2
192.168.199.20 worker-0
192.168.199.21 worker-1
192.168.199.22 worker-2

192.168.199.30 traefik-0
192.168.199.40 api.k8s.virtualbox
192.168.199.50 nfserver-0
EOF
