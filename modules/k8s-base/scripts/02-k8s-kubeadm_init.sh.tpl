#!/bin/bash -xe
#02-k8s-kubeadm_init.sh


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
#Enabling virtual IP environment
sudo bash -c 'cat <<EOF > /etc/sysctl.d/12-haproxy_allow_virtual_ip.conf
net.ipv4.ip_nonlocal_bind=1
EOF'
sudo chown root:root /etc/sysctl.d/12-haproxy_allow_virtual_ip.conf && sudo chmod 644 /etc/sysctl.d/12-haproxy_allow_virtual_ip.conf
sudo sysctl --system

#Enabling keepalived
sudo bash -c 'cat <<EOF > /etc/keepalived/keepalived.conf
# File: /etc/keepalived/keepalived.conf

global_defs {
    enable_script_security
    script_user nobody
}

vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth0
    virtual_router_id 5
    priority 100
    advert_int 1
    nopreempt
    authentication {
        auth_type PASS
        auth_pass ${k8s-vrrp_random_pass}
    }
    virtual_ipaddress {
        ${k8s_api_endpoint_ip}
    }
    track_script {
        check_apiserver
    }
}
EOF'
sudo bash -c 'cat <<EOF > /etc/keepalived/check_apiserver.sh
#!/bin/sh
# File: /etc/keepalived/check_apiserver.sh

errorExit() {
    echo "*** $*" 1>&2
    exit 1
}

curl --silent --max-time 2 --insecure ${k8s_api_endpoint_proto}://localhost:${k8s_api_endpoint_port}/ -o /dev/null || errorExit "Error GET ${k8s_api_endpoint_proto}://localhost:${k8s_api_endpoint_port}/"
if ip addr | grep -q "${k8s_api_endpoint_ip}"; then
    curl --silent --max-time 2 --insecure ${k8s_api_endpoint_proto}://${k8s_api_endpoint_ip}:${k8s_api_endpoint_port}/ -o /dev/null || errorExit "Error GET ${k8s_api_endpoint_proto}://${k8s_api_endpoint_ip}:${k8s_api_endpoint_port}/"
fi
EOF'
sudo bash -c 'chmod +x /etc/keepalived/check_apiserver.sh'
sudo bash -c 'systemctl enable keepalived'
sudo bash -c 'systemctl start keepalived'

#Enabling haproxy
sudo bash -c 'cat <<EOF > /etc/haproxy/haproxy.cfg
# File: /etc/haproxy/haproxy.cfg
#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    log /dev/log local0
    log /dev/log local1 notice
    daemon

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    ${k8s_api_endpoint_proto}
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 1
    timeout http-request    10s
    timeout queue           20s
    timeout connect         5s
    timeout client          20s
    timeout server          20s
    timeout http-keep-alive 10s
    timeout check           10s

#---------------------------------------------------------------------
# apiserver frontend which proxys to the control plane nodes
#---------------------------------------------------------------------
frontend apiserver
    bind *:${k8s_api_endpoint_port}
    mode tcp
    option tcplog
    default_backend apiserver

#---------------------------------------------------------------------
# round robin balancing for apiserver
#---------------------------------------------------------------------
backend apiserver
    option httpchk GET /healthz
    http-check expect status 200
    mode tcp
    option ssl-hello-chk
    balance     roundrobin
EOF'
j=${master_node_address_start_ip}
for ((i=0; i<${master_count}; i++))
do
 echo "        server node$((i+1)) ${master_network_mask}$j:6443 check" | sudo tee -a /etc/haproxy/haproxy.cfg
 ((j++))
done
#Enabling k8s with kubeadm
if [[ ${master_count} -eq 1 && ${itterator} -eq 0 ]] || [[ ${master_count} -gt 1 && ${itterator} -eq 0 ]]
then
	mkdir -p "$HOME"/.kube
    set +xe
    sudo bash -c 'systemctl enable haproxy'
    sudo bash -c 'systemctl restart haproxy'
    set -xe
	sudo bash -c 'kubeadm init --control-plane-endpoint=${k8s_api_endpoint_ip} --apiserver-advertise-address=${k8s_api_endpoint_ip} --pod-network-cidr=${pod-network-cidr} --upload-certs > /tmp/kubeadm_init.log 2>&1'
	sudo --preserve-env=HOME bash -c 'echo "export KUBECONFIG="$HOME"/.kube/config" > /etc/environment'
	sudo --preserve-env=HOME bash -c 'export KUBECONFIG="$HOME"/.kube/config'
	sudo --preserve-env=HOME bash -c 'cp -f /etc/kubernetes/admin.conf "$HOME"/.kube/config'
	sudo chown "$(id -u)":"$(id -g)" "$HOME"/.kube/config
	sudo bash -c 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version'
	sudo bash -c 'ctr images pull docker.io/library/hello-world:latest'
	sudo bash -c 'ctr run docker.io/library/hello-world:latest hello-world'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo bash -c 'echo "K8s init with 1 control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init'
elif [[ ${master_count} -eq 3 ]] && [[ ${itterator} -gt 0 ]]
then
	echo "${itterator}"
	sudo bash -c 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version'
	sudo bash -c 'ctr images pull docker.io/library/hello-world:latest'
	sudo bash -c 'ctr run docker.io/library/hello-world:latest hello-world'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo bash -c 'echo "K8s init with 3 control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init'
elif [[ ${master_count} -gt 3 ]] && [[ ${itterator} -gt 0 ]]
then
	echo "${itterator}"
	sudo bash -c 'crictl --runtime-endpoint unix:///var/run/containerd/containerd.sock version'
	sudo bash -c 'ctr images pull docker.io/library/hello-world:latest'
	sudo bash -c 'ctr run docker.io/library/hello-world:latest hello-world'
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo bash -c 'echo "K8s init with ${master_count} control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init'
else
	echo "${itterator}"
	sudo bash -c 'echo `date` > /var/lib/cloud/instance/02-k8s-kubeadm_init'
	sudo bash -c 'echo "ERROR: K8s init FAILED with ${master_count} control plane master" >> /var/lib/cloud/instance/02-k8s-kubeadm_init'
	exit -1
fi	