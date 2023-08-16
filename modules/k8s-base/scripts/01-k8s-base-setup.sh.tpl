#!/bin/bash -xe
#01-k8s-base-setup.sh


set -o errexit

#cloud-init-wait
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo -e "\033[1;36mWaiting for cloud-init..."
  sleep 10
done
sudo bash -c 'apt get update'
sudo bash -c 'apt get upgrade'
sudo bash -c 'cat <<EOF > /etc/sysctl.d/11-kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF'
sudo chown root:root /etc/sysctl.d/11-kubernetes.conf && sudo chmod 644 /etc/sysctl.d/11-kubernetes.conf
sudo sysctl --system
sudo bash -c 'cat <<EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF'
sudo chown root:root /etc/modules-load.d/containerd.conf && sudo chmod 644 /etc/modules-load.d/containerd.conf
sudo modprobe overlay
sudo modprobe br_netfilter
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
sudo echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubeadm kubectl kubelet keepalived haproxy
wget https://github.com/containerd/containerd/releases/download/v${version_containerd}/containerd-${version_containerd}-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-${version_containerd}-linux-amd64.tar.gz
sudo rm containerd-${version_containerd}-linux-amd64.tar.gz
sudo mkdir /etc/containerd/
sudo bash -c 'containerd config default > /etc/containerd/config.toml'
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /etc/systemd/system/
wget https://github.com/opencontainers/runc/releases/download/v${version_runc}/runc.amd64
sudo bash -c 'install -m 755 runc.amd64 /usr/local/sbin/runc'
rm runc.amd64
wget https://github.com/containernetworking/plugins/releases/download/v${version_cni-plugin}/cni-plugins-linux-amd64-v${version_cni-plugin}.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v${version_cni-plugin}.tgz
rm cni-plugins-linux-amd64-v${version_cni-plugin}.tgz
sudo systemctl daemon-reload
sudo systemctl enable --now containerd
sudo bash -c 'echo `date` > /var/lib/cloud/instance/01-k8s-base-setup'
sudo bash -c 'echo "K8s dependencies install" >> /var/lib/cloud/instance/01-k8s-base-setup'
sudo bash -c 'cat <<EOF >> /var/lib/cloud/instance/01-k8s-base-setup
Containerd version      -- ${version_containerd}
Containerd config file  -- /etc/containerd/config.toml
Containerd service file -- /etc/systemd/system/containerd.service
Runc version            -- ${version_runc}
Runc file location      -- /usr/local/sbin/runc
CNI-pligin version      -- ${version_cni-plugin}
EOF'