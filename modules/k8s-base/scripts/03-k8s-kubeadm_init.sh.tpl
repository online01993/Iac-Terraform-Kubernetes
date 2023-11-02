#!/bin/bash -xe
#03-k8s-kubeadm_init.sh


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
#02-k8s-ha-setup-wait
while [ ! -f /var/lib/cloud/instance/02-k8s-ha-setup ]; do
  echo -e "\033[1;36mWaiting for 02-k8s-ha-setup..."
  sleep 10
done
if [[ -f /var/lib/cloud/instance/03-k8s-kubeadm_init ]]
then
  echo "not first run, exit"
  exit 0
fi  
#Enabling k8s with kubeadm
if [[ ${master_count} -eq 1 && ${itterator} -eq 0 ]] || [[ ${master_count} -gt 1 && ${itterator} -eq 0 ]]
then
	mkdir -p "$HOME"/.kube
	sudo bash -c 'kubeadm init --control-plane-endpoint="${k8s_api_endpoint_ip}:${k8s_api_endpoint_port}" --pod-network-cidr=${pod-network-cidr} --upload-certs > /tmp/kubeadm_init.log 2>&1'
	sudo --preserve-env=HOME bash -c 'echo "export KUBECONFIG="$HOME"/.kube/config" > /etc/environment'
	sudo --preserve-env=HOME bash -c 'export KUBECONFIG="$HOME"/.kube/config'
	sudo --preserve-env=HOME bash -c 'cp -f /etc/kubernetes/admin.conf "$HOME"/.kube/config'
	sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
	sudo bash -c 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version'
	sudo bash -c 'ctr images pull docker.io/library/hello-world:latest'
	sudo bash -c 'ctr run docker.io/library/hello-world:latest hello-world'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/03-k8s-kubeadm_init'
	sudo bash -c 'echo "K8s init with 1 control plane master" >> /var/lib/cloud/instance/03-k8s-kubeadm_init'
elif [[ ${master_count} -eq 3 ]] && [[ ${itterator} -gt 0 ]]
then
	echo "${itterator}"
	sudo bash -c 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version'
	sudo bash -c 'ctr images pull docker.io/library/hello-world:latest'
	sudo bash -c 'ctr run docker.io/library/hello-world:latest hello-world'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/03-k8s-kubeadm_init'
	sudo bash -c 'echo "K8s init with 3 control plane master" >> /var/lib/cloud/instance/03-k8s-kubeadm_init'
elif [[ ${master_count} -gt 3 ]] && [[ ${itterator} -gt 0 ]]
then
	echo "${itterator}"
	sudo bash -c 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version'
	sudo bash -c 'ctr images pull docker.io/library/hello-world:latest'
	sudo bash -c 'ctr run docker.io/library/hello-world:latest hello-world'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/03-k8s-kubeadm_init'
	sudo bash -c 'echo "K8s init with ${master_count} control plane master" >> /var/lib/cloud/instance/03-k8s-kubeadm_init'
else
	echo "${itterator}"
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/03-k8s-kubeadm_init'
	sudo bash -c 'echo "ERROR: K8s init FAILED with ${master_count} control plane master" >> /var/lib/cloud/instance/03-k8s-kubeadm_init'
	exit -1
fi	