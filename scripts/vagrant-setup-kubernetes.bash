# Install CRI/CNI
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xz -f /vagrant/download/cni-plugins.tgz

# TBD
# mkdir -p /opt/bin
# tar -C /opt/bin -xz -f /vagrant/download/crictl.tgz

# Install Docker CE
apt-get update
apt-get install libltdl7
dpkg -i /vagrant/download/docker-ce.deb

# Setup daemon.
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

# Restart docker
mkdir -p /etc/systemd/system/docker.service.d
systemctl daemon-reload && systemctl restart docker

# Installing kubeadm, kubelet and kubectl
chmod +x /vagrant/download/{kubeadm,kubelet,kubectl}
cp /vagrant/download/{kubeadm,kubelet,kubectl} /usr/bin/
cp /vagrant/download/kubelet.service /etc/systemd/system/kubelet.service
mkdir -p /etc/systemd/system/kubelet.service.d
cp /vagrant/download/10-kubeadm.conf /etc/systemd/system/kubelet.service.d

# kubelet requires swap off
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab

# kubelet will keep restarting because config files are not initialized. 
systemctl enable --now kubelet