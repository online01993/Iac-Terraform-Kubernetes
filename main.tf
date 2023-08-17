module "infrastructure" {
  source = "./modules/infrastructure"
  #make linking vars from source and tfvars
  master_cpu_count             = var.global_master_cpu_count
  xen_network_name             = var.global_xen_network_name
  xen_vm_template_name         = var.global_xen_vm_template_name
  xen_pool_name                = var.global_xen_pool_name
  node_count                   = var.global_node_count
  master_count                 = var.global_master_node_high_availability == true ? 3 : 1
  master_disk_size_gb          = var.global_master_disk_size_gb
  vm_disk_size_gb              = var.global_vm_disk_size_gb
  master_memory_size_gb        = var.global_master_memory_size_gb
  vm_rsa_ssh_key               = var.global_vm_rsa_ssh_key
  xen_sr_id                    = var.global_xen_sr_id
  xen_large_sr_id              = var.global_xen_large_sr_id
  master_labels                = var.global_master_labels
  node_labels                  = var.global_node_labels
  master_vm_tags               = var.global_master_vm_tags
  node_vm_tags                 = var.global_node_vm_tags
  certificate_params           = var.global_certificate_params
  vm_storage_disk_size_gb      = var.global_vm_storage_disk_size_gb
  dns_key_name                 = var.global_dns_key_name
  dns_key_secret               = var.global_dns_key_secret
  vm_memory_size_gb            = var.global_vm_memory_size_gb
  vm_cpu_count                 = var.global_vm_cpu_count
  dns_server                   = var.global_dns_server
  dns_zone                     = var.global_dns_zone
  dns_sub_zone                 = var.global_dns_sub_zone
  master_node_address_mask     = var.global_master_node_address_mask
  master_node_address_start_ip = var.global_master_node_address_start_ip
  worker_node_address_mask     = var.global_worker_node_address_mask
  worker_node_address_start_ip = var.global_worker_node_address_start_ip
  nodes_mask                   = var.global_nodes_mask
  nodes_gateway                = var.global_nodes_gateway
  nodes_dns_address            = var.global_nodes_dns_address
  master_node_network_dhcp     = var.global_master_node_network_dhcp
  worker_node_network_dhcp     = var.global_worker_node_network_dhcp
}
module "kubernetes-base" {
  depends_on                   = [module.infrastructure]
  source                       = "./modules/k8s-base"
  vm_rsa_ssh_key_public        = module.infrastructure.vm_rsa_ssh_key_public
  vm_rsa_ssh_key_private       = module.infrastructure.vm_rsa_ssh_key_private
  masters                      = module.infrastructure.masters
  nodes                        = module.infrastructure.nodes
  master_count                 = var.global_master_node_high_availability == true ? 3 : 1
  master_node_address_mask     = var.global_master_node_address_mask
  master_node_address_start_ip = var.global_master_node_address_start_ip
  version_containerd           = var.global_version_containerd
  version_runc                 = var.global_version_runc
  version_cni-plugin           = var.global_version_cni-plugin
  k8s_api_endpoint_ip          = var.global_k8s_api_endpoint_ip
  k8s_api_endpoint_port        = var.global_k8s_api_endpoint_port
  k8s_cni_hairpinMode          = var.global_k8s_cni_hairpinMode
  k8s_cni_isDefaultGateway     = var.global_k8s_cni_isDefaultGateway
  k8s_cni_Backend_Type         = var.global_k8s_cni_Backend_Type
  pods_mask_cidr               = "${var.global_pods_address_mask}/${var.global_pods_mask_cidr}"
}
module "kubernetes-services" {
  depends_on                   = [module.kubernetes-base]
  source                       = "./modules/k8s-services"
  kube-dashboard_nodePort      = var.global_kube-dashboard_nodePort
}  