# MAIN FILE TO VARIABLES SET
#
# XO XCP-ng settings
#
#Address to connect XO orhestra for xen mgmt
global_xen_xoa_url = "ws://10.1.84.212"
#XO orhestra login username
global_xen_xoa_username = "admin"
#XO orhestra login password
global_xen_xoa_password = "nt[yjkjubz"
#XO use secure ssl false|true
global_xen_xoa_insecure = true
#XO xcp-ng/xenserver pool
global_xen_pool_name = "xcp-ng-homepool"
#Network for VM
global_xen_network_name = "Network 0 - LAN"
#Xen template VM to clone
global_xen_vm_template_name = "templateDebianCloudReadyWithXenUtils"
#Xen fast SR ID 
global_xen_sr_id = [
  "0714cdc3-2eea-f339-f10c-4777c715400a"
]
#Xen large SR ID`s 
global_xen_large_sr_id = [
  #"UUID",
  "60121d03-b7c4-6f8b-4c70-1d6e93b89004"
]

#
# DNS + certificate Global settings
#
#DNS Key name to DNS bind configure
global_dns_key_name = "lopati-magazin.local."
#DNS Key name for DNS bind mgmt - secret
global_dns_key_secret = "supersecret"
#IP/FQDN DNS Bind Server
global_dns_server = "wsus.its.local"
#DNS primary zone name
global_dns_zone = "its.local."
#DNS additional sub zone name
global_dns_sub_zone = "k8s"
#Certificates params
global_certificate_params = {
  organization        = "lopati-magazin"
  organizational_unit = "Labs"
  locality            = "Novosibirsk"
  country             = "RU"
  province            = "NSK"
}

#
# VM settings
#
#Master node IP address mask
global_master_node_address_mask = "10.244.0."
#Worker node IP address mask
global_worker_node_address_mask = "10.244.1."
#Nodes mask, default /16
global_nodes_mask" = "255.255.0.0"
#Nodes gateway address
global_nodes_gateway = "10.244.0.1"
#Nodes DNS server address
global_nodes_dns_address = "10.244.0.1"
#Count for VM master node
#need minimal 3 for Kubernetes etcd и controlplane ( 3 для HA)
#https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
global_master_count = 3
#Count for VM worker node
#need minimal 3 node workers for HA kubernetes data
#https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/
global_node_count = 3
#Size for VM master node system disk size
global_master_disk_size_gb = 16
#Size for VM worker node system disk size
global_vm_disk_size_gb = 16
#Size for VM worker node k8s data disk size
global_vm_storage_disk_size_gb = 20
#Count for CPU VM master node #Kubernetes minimal 2
global_master_cpu_count = 2
#Count for CPU VM worker node #Kubernetes minimal 2
global_vm_cpu_count = 2
#Count for MEM VM master node #Kubernetes minimal 2
global_master_memory_size_gb = 2
#Count for CPU VM worker node #Kubernetes minimal 2
global_vm_memory_size_gb = 2
#Lables for VM master node
global_master_labels = {
  "ntmax.ca/cloud-platform" = "xcp-ng"
  "ntmax.ca/cloud-os"       = "debian-11-focal"
  "ntmax.ca/region"         = "mtl-south-1"
}
#Lables for VM worker node
global_node_labels = {
  "ntmax.ca/cloud-platform" = "xcp-ng"
  "ntmax.ca/cloud-os"       = "debian-11-focal"
  "ntmax.ca/region"         = "mtl-south-1"
}
#Tags for VM master node
global_master_vm_tags = [
  "ntmax.ca/cloud-os:debian-11-focal",
  "ntmax.ca/middleware:kubernetes",
  "ntmax.ca/provisionning:ansible",
  "ntmax.ca/provisionning:terraform",
  "kubernetes.io/role:master"
]
#Tags for VM worker node
global_node_vm_tags = [
  "ntmax.ca/cloud-os:debian-11-focal",
  "ntmax.ca/middleware:kubernetes",
  "ntmax.ca/provisionning:ansible",
  "ntmax.ca/provisionning:terraform",
  "kubernetes.io/role:worker"
]
#VM common SSH pub key to its user
global_vm_rsa_ssh_key = <<EOF
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCt5+QyPfxJ6UB0aOn9HvEn9bX3HGy/6i0ibZpkJjBKAQAgV5GBgBihjCm5D2CevI7WOvBXrR6JXPgu0wQSAv9cNyi8Tpvia6IhE1Jva8Fp3JMnig1+dmhqu69goBfPNrmTO/33+GqJ6cGx80EuVsnQGnqcIIfEHo+n50ZNhKXEPzPaOCQfBjwMPXrl2mX0WBkUW3oXh7VkaYHA2mX8KgRKjgxX2Ws8uAzZ+k0N3qBUIWWzoempIIXuCGzvt9XpOjfYM+dXbbj9Ux4qqC8uPM9wnQYcMAUG0N061oClp9vJEeGvY3z01d8ISpmNAooAMcbpMj18Dzt8jogQ831bsyhzco0PEzipZQUWs3RLwTxgInyZCZFpwd/GRnkl0fHIPNbzIGjoDMIywy1CJKqa1vJLoJccNDAki2tIsUqCJXghCmbkUA+D8QA8IyNkmCDa8pDbH7/NuujvD22vpA6sp6kYF2I9KdF3nqtlyWRG0JYal8SIoiUwv2oJ3i6V2uI6Drs= n.nikitashin@nick-mgmt

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrSoLe1bqObD8Eh+7dhMRd66g9m3/wVqviFNdxyDLIDa89lf3o56Lvd3uLEgVrGxZxFHFApCuVuujxDRumiw7wN1R6cPgQdcKb834M8v38mmb3IokIqb/+38nPPAiEs5TR/qNkEXtajASkMGObDkhwb8uPh4B92FOvk8BHMadmNPxoVp4WJSy314At4K2EPK4DKk8O+cEVs+JwplQxLA8S6oNY7eztNcTRpF/wCJ7BUDKKMnNki2eWCjYD946RW4/LScKtTN410iVa4kW1mj50NNHCTLrxniwg9MP+xrP0Z1qf1vT8ihT3OAzLaYigK3WO9X5U1K/+Sv8MIOBxiZMSTdWwNbxk/mh98EGdluY2U5e5yWU4vC88UZElS33N/B1BiuPOzV7U+SYWMpUTE46dgNhd9ZJk2fm0lU3zY048lRAXS4tbrqKZeb4qsbkNshKqAOUpnevosBT4UAoOSHgqWo9qQmYBphD+ZqFZyKC+pmNXa1Cd40V4I+V1LM0JvQM= a.teremshonok"

EOF
#need to be here
#https://github.com/terraform-linters/tflint-ruleset-aws/issues/42#issuecomment-928199917