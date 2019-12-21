# create etcd static pod manifest for kubelet
cat << EOF > /etc/systemd/system/kubelet.service.d/20-etcd-service-manager.conf
[Service]
ExecStart=
#  Replace "systemd" with the cgroup driver of your container runtime. The default value in the kubelet is "cgroupfs".
ExecStart=/usr/bin/kubelet --address=127.0.0.1 --pod-manifest-path=/etc/kubernetes/manifests --cgroup-driver=systemd
Restart=always
EOF
systemctl daemon-reload && systemctl restart kubelet

# generate etcd certificates, reuse etcd-ca under /vagrant/config/pki
mkdir -p /etc/kubernetes/pki
cp -r /vagrant/config/pki /etc/kubernetes/
ID=`hostname | sed 's/master-//'`
IP_ADDR=`ifconfig enp0s8 | grep 'inet addr' | awk '{print $2}'| cut -f2 -d:`

cat << EOF > /tmp/etcd.yaml
apiVersion: "kubeadm.k8s.io/v1beta2"
kind: ClusterConfiguration
etcd:
  local:
    serverCertSANs:
    - "${IP_ADDR}"
    peerCertSANs:
    - "${IP_ADDR}"
    extraArgs:
      initial-cluster: etcd0=https://192.168.199.10:2380,etcd1=https://192.168.199.11:2380,etcd2=https://192.168.199.12:2380
      initial-cluster-state: new
      name: etcd${ID}
      listen-peer-urls: https://${IP_ADDR}:2380
      listen-client-urls: https://${IP_ADDR}:2379
      advertise-client-urls: https://${IP_ADDR}:2379
      initial-advertise-peer-urls: https://${IP_ADDR}:2380
      heartbeat-interval: "250"
      election-timeout: "1250"
EOF

kubeadm init phase certs etcd-server --config="/tmp/etcd.yaml"
kubeadm init phase certs etcd-peer --config="/tmp/etcd.yaml"
kubeadm init phase certs etcd-healthcheck-client --config="/tmp/etcd.yaml"
kubeadm init phase certs apiserver-etcd-client --config="/tmp/etcd.yaml"

# generate /etc/kubernetes/manifests/etcd.yaml
kubeadm init phase etcd local --config="/tmp/etcd.yaml"

# reload service file and restart kubelet service
systemctl daemon-reload && systemctl restart kubelet