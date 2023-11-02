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
if [[ -f /var/lib/cloud/instance/04-k8s-kubeadm-join_nodes ]]
then
  echo "not first run, exit"
  exit 0
fi 
#wait base init-kubeadm on first master
sleep 10
sudo bash -c '${kubeadm-join_string} > /var/lib/cloud/instance/04-k8s-kubeadm-join_nodes 2>&1'
sudo bash -c 'echo `date` >> /var/lib/cloud/instance/04-k8s-kubeadm-join_nodes'
sudo bash -c 'echo "K8s adding current node ${itterator} to cluster" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_nodes'