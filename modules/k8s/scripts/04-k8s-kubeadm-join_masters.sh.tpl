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
if [[ ${master_count} -eq 1 && ${itterator} -eq 0 ]] || [[ ${master_count} -gt 1 && ${itterator} -eq 0 ]]
then
	#dont do anything for first master node
    exit 0
elif [[ ${master_count} -eq 3 ]] && [[ ${itterator} -gt 0 ]]
then
	#wait base init-kubeadm on first master
	if [[ -f /etc/haproxy/haproxy.cfg ]] && [[ -f /etc/keepalived/keepalived.conf ]]
	then
	 set +xe
     sudo bash -c 'systemctl enable haproxy'
     sudo bash -c 'systemctl restart haproxy'
     set -xe
    else
	 sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	 sudo bash -c 'echo "ERROR: K8s adding FAILED with ${master_count} control plane master - /etc/haproxy/haproxy.cfg or /etc/keepalived/keepalived.conf NOT FOUND!!!" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	 exit -1
    fi	 
	sudo bash -c '${kubeadm-join_string}'
	sudo --preserve-env=HOME bash -c 'echo "export KUBECONFIG="$HOME"/.kube/config" > /etc/environment'
	sudo --preserve-env=HOME bash -c 'export KUBECONFIG="$HOME"/.kube/config'
	sudo --preserve-env=HOME bash -c 'cp -f /etc/kubernetes/admin.conf "$HOME"/.kube/config'
	sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	sudo bash -c 'echo "K8s adding current node ${master_count} as control plane master" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
elif [[ ${master_count} -gt 3 ]] && [[ ${itterator} -gt 0 ]]
then
    #wait base init-kubeadm on first master
	if [[ -f /etc/haproxy/haproxy.cfg ]] && [[ -f /etc/keepalived/keepalived.conf ]]
	then
	 set +xe
     sudo bash -c 'systemctl enable haproxy'
     sudo bash -c 'systemctl restart haproxy'
     set -xe
    else
	 sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	 sudo bash -c 'echo "ERROR: K8s adding FAILED with ${master_count} control plane master - /etc/haproxy/haproxy.cfg or /etc/keepalived/keepalived.conf NOT FOUND!!!" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	 exit -1
    fi
	sudo --preserve-env=HOME bash -c 'echo "export KUBECONFIG="$HOME"/.kube/config" > /etc/environment'
	sudo --preserve-env=HOME bash -c 'export KUBECONFIG="$HOME"/.kube/config'
	sudo --preserve-env=HOME bash -c 'cp -f /etc/kubernetes/admin.conf "$HOME"/.kube/config'
	sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
	sudo bash -c '${kubeadm-join_string}'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	sudo bash -c 'echo "K8s adding current node ${master_count} as control plane master" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
else
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	sudo bash -c 'echo "ERROR: K8s adding FAILED with ${master_count} control plane master" >> /var/lib/cloud/instance/04-k8s-kubeadm-join_masters'
	exit -1
fi	