#this file need to link varribles from root main.tf to modules in sub-dir
#https://discuss.hashicorp.com/t/trying-to-understand-input-variables-tfvars-variables-tf/22324/4
variable "global_master_cpu_count" {}
variable "global_xen_network_name" {}
variable "global_xen_vm_template_name" {}
variable "global_xen_pool_name" {}
variable "global_xen_xoa_url" {}
variable "global_xen_xoa_username" {}
variable "global_xen_xoa_password" {}
variable "global_xen_xoa_insecure" {}
variable "global_node_count" {}
variable "global_master_disk_size_gb" {}
variable "global_vm_disk_size_gb" {}
variable "global_master_memory_size_gb" {}
variable "global_vm_rsa_ssh_key" {}
variable "global_xen_sr_id" {}
variable "global_xen_large_sr_id" {}
variable "global_master_labels" {}
variable "global_node_labels" {}
variable "global_master_vm_tags" {}
variable "global_node_vm_tags" {}
variable "global_certificate_params" {}
variable "global_vm_storage_disk_size_gb" {}
variable "global_dns_key_name" {}
variable "global_dns_key_secret" {}
variable "global_vm_memory_size_gb" {}
variable "global_vm_cpu_count" {}
variable "global_dns_server" {}
variable "global_dns_zone" {}
variable "global_dns_sub_zone" {}
variable "global_master_node_address_mask" {}
variable "global_master_node_address_start_ip" {}
variable "global_worker_node_address_mask" {}
variable "global_worker_node_address_start_ip" {}
variable "global_nodes_mask" {}
variable "global_nodes_gateway" {}
variable "global_nodes_dns_address" {}
variable "global_pods_address_mask" {}
variable "global_pods_mask_cidr" {}
variable "global_master_node_network_dhcp" {}
variable "global_worker_node_network_dhcp" {}
variable "global_master_node_high_availability" {
  type        = bool
  description = "If this is a multiple instance deployment, choose `true` to deploy 3 instances"
  default     = true
}
variable "global_version_containerd" {}
variable "global_version_runc" {}
variable "global_version_cni-plugin" {}
variable "global_k8s_api_endpoint_ip" {}
variable "global_k8s_api_endpoint_port" {}
variable "global_k8s_api_endpoint_proto" {}

locals {
  vm_rsa_ssh_key_public  = module.infrastructure.vm_rsa_ssh_key_public
  vm_rsa_ssh_key_private = module.infrastructure.vm_rsa_ssh_key_private
}