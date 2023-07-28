#!/bin/bash -xe
#04-k8s-kubeadm-join_nodes.sh


set -o errexit

#cloud-init-wait
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo -e "\033[1;36mWaiting for cloud-init..."
  sleep 10
done
#01-k8s-base-setup-wait
while [ ! -f /var/lib/cloud/instance/01-k8s-base-setup ]; do
  echo -e "\033[1;36mWaiting for 01-k8s-base-setup..."
  sleep 10
done
sudo bash -c '${kubeadm-join_string} &> /tmp/kubeadm.log'
sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_nodes'
sudo bash -c 'echo "K8s adding current node ${itterator} to cluster" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_nodes'