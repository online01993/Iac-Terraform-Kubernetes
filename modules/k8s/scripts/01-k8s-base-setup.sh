#!/bin/bash

sudo cat <<EOF > /etc/sysctl.d/11-kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sudo chown root:root /etc/sysctl.d/11-kubernetes.conf && sudo chmod 644 /etc/sysctl.d/11-kubernetes.conf
sudo sysctl --system


sudo cat <<EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF
sudo chown root:root /etc/modules-load.d/containerd.conf && sudo chmod 644 /etc/modules-load.d/containerd.conf
sudo modprobe overlay
sudo modprobe br_netfilter



curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg
sudo echo "deb [signed-by=/etc/apt/trusted.gpg.d/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update
sudo apt install -y kubeadm kubectl keepalived haproxy
wget https://github.com/containerd/containerd/releases/download/v1.7.2/containerd-1.7.2-linux-amd64.tar.gz
sudo tar Cxzvf /usr/local containerd-1.7.2-linux-amd64.tar.gz
sudo rm containerd-1.7.2-linux-amd64.tar.gz
sudo mkdir /etc/containerd/
sudo containerd config default > /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
wget https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
sudo mv containerd.service /etc/systemd/system/
wget https://github.com/opencontainers/runc/releases/download/v1.1.7/runc.amd64
sudo install -m 755 runc.amd64 /usr/local/sbin/runc
rm runc.amd64
wget https://github.com/containernetworking/plugins/releases/download/v1.3.0/cni-plugins-linux-amd64-v1.3.0.tgz
sudo mkdir -p /opt/cni/bin
sudo tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.3.0.tgz
rm cni-plugins-linux-amd64-v1.3.0.tgz
sudo systemctl daemon-reload
sudo systemctl enable --now containerd