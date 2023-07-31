#!/bin/bash -xe
#04-k8s-kubeadm-join_masters.sh


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
#02-k8s-kubeadm_init-wait
while [ ! -f /var/lib/cloud/instance/01-k8s-base-setup ]; do
  echo -e "\033[1;36mWaiting for 01-k8s-base-setup..."
  sleep 10
done
if [[ ${master_count} -eq 1 ]] && [[ ${itterator} -eq 0 ]]
then
	#dont do anything for himself
    exit 0
elif [[ ${master_count} -eq 3 ]] && [[ ${itterator} -gt 0 ]]
then
	#wait base init-kubeadm
	sleep 30
	sudo bash -c '${kubeadm-join_string}'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	sudo bash -c 'echo "K8s adding current node ${master_count} as control plane master" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
elif [[ ${master_count} -gt 3 ]]
then
    #wait base init-kubeadm
	sleep 30
	sudo bash -c '${kubeadm-join_string}'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	sudo bash -c 'echo "K8s adding current node ${master_count} as control plane master" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
else
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	sudo bash -c 'echo "ERROR: K8s adding FAILED with ${master_count} control plane master" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	exit -1
fi	