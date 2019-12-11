#!/bin/bash

set -euo pipefail

apt-get install -y nfs-kernel-server
mkdir -p /mnt/vagrant-kubernetes
mkdir -p /mnt/vagrant-kubernetes/data
chown nobody:nogroup /mnt/vagrant-kubernetes
chmod 777 /mnt/vagrant-kubernetes

# /etc/exports 
sh -c "echo '/mnt/vagrant-kubernetes 192.168.199.0/24(rw,sync,no_subtree_check,insecure,no_root_squash)' >> /etc/exports"
exportfs -a
systemctl restart nfs-kernel-server    
exportfs -v