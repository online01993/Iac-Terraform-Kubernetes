#this file need to link varribles from root main.tf to modules in sub-dir
#https://discuss.hashicorp.com/t/trying-to-understand-input-variables-tfvars-variables-tf/22324/4
variable "global_xen_xoa_url" {}
variable "global_xen_xoa_username" {}
variable "global_xen_xoa_password" {}
variable "global_xen_xoa_insecure" {}
variable "global_xen_infra_settings" {}


variable "global_pods_address_mask" {}
variable "global_pods_mask_cidr" {}
variable "global_master_node_address_mask" {}
variable "global_master_node_address_start_ip" {}
variable "global_version_containerd" {}
variable "global_version_runc" {}
variable "global_version_cni-plugin" {}
variable "global_k8s_api_endpoint_ip" {}
variable "global_k8s_api_endpoint_port" {}
variable "global_k8s_cni_hairpinMode" {}
variable "global_k8s_cni_isDefaultGateway" {}
variable "global_k8s_cni_Backend_Type" {}
variable "global_kube-dashboard_nodePort" {}
variable "global_ssd_k8s_stor_pool_type" {}
variable "global_ssd_k8s_stor_pool_name" {}
variable "global_nvme_k8s_stor_pool_type" {}
variable "global_nvme_k8s_stor_pool_name" {}
variable "global_hdd_k8s_stor_pool_type" {}
variable "global_hdd_k8s_stor_pool_name" {}