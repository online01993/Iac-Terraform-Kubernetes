#!/bin/bash -xe
#02-k8s-kubeadm_init.sh


set -o errexit

#cloud-init-wait
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
  echo -e "\033[1;36mWaiting for cloud-init..."
  sleep 1
done
#01-k8s-base-setup-wait
while [ ! -f /var/lib/cloud/instance/01-k8s-base-setup ]; do
  echo -e "\033[1;36mWaiting for 01-k8s-base-setup..."
  sleep 1
done
if [[ ${master_count} -eq 1 ]] && [[ ${itterator} -eq 0 ]]
then
	sudo kubeadm init --pod-network-cidr=${pod-network-cidr}
	sudo bash -c 'echo "export KUBECONFIG=/etc/kubernetes/admin.conf" > /etc/environment'
	sudo bash -c 'export KUBECONFIG=/etc/kubernetes/admin.conf'
	sudo kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
	sudo bash -c 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version'
	sudo bash -c 'ctr images pull docker.io/library/hello-world:latest'
	sudo bash -c 'ctr run docker.io/library/hello-world:latest hello-world'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo echo "K8s init with 1 control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init
elif [[ ${master_count} -eq 3 ]]
then
	echo "${itterator}"
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo echo "K8s init with 3 control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init
elif [[ ${master_count} -gt 3 ]]
then
	echo "${itterator}"
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo echo "K8s init with ${master_count} control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init
else
    echo "${itterator}"
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo echo "ERROR: K8s init FAILED with ${master_count} control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init
	exit -1
fi	