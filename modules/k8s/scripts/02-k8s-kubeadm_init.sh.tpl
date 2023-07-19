#!/bin/bash -xe
#02-k8s-kubeadm_init.sh


set -o errexit

#cloud-init-wait
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo -e "\033[1;36mWaiting for cloud-init..."
  sleep 1
done

${vm_rsa_ssh_key}

#yum update -y

#yum install -y zip unzip






crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version
ctr images pull docker.io/library/hello-world:latest
ctr run docker.io/library/hello-world:latest hello-world