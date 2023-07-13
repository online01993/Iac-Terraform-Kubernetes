module "infrastructure" {
  source = "./modules/infrastructure"
  #make linking vars from source and tfvars
  master_cpu_count        = var.global_master_cpu_count
  xen_network_name        = var.global_xen_network_name
  xen_vm_template_name    = var.global_xen_vm_template_name
  xen_pool_name           = var.global_xen_pool_name
  xen_xoa_url             = var.global_xen_xoa_url
  xen_xoa_username        = var.global_xen_xoa_username
  xen_xoa_password        = var.global_xen_xoa_password
  xen_xoa_insecure        = var.global_xen_xoa_insecure
  node_count              = var.global_node_count
  master_count            = var.global_master_count
  master_disk_size_gb     = var.global_master_disk_size_gb
  vm_disk_size_gb         = var.global_vm_disk_size_gb
  master_memory_size_gb   = var.global_master_memory_size_gb
  vm_rsa_ssh_key          = var.global_vm_rsa_ssh_key
  xen_sr_id               = var.global_xen_sr_id
  xen_large_sr_id         = var.global_xen_large_sr_id
  master_labels           = var.global_master_labels
  node_labels             = var.global_node_labels
  master_vm_tags          = var.global_master_vm_tags
  node_vm_tags            = var.global_node_vm_tags
  certificate_params      = var.global_certificate_params
  vm_storage_disk_size_gb = var.global_vm_storage_disk_size_gb
  dns_key_name            = var.global_dns_key_name
  dns_key_secret          = var.global_dns_key_secret
  vm_memory_size_gb       = var.global_vm_memory_size_gb
  vm_cpu_count            = var.global_vm_cpu_count
  dns_server              = var.global_dns_server
  dns_zone                = var.global_dns_zone
  dns_sub_zone            = var.global_dns_sub_zone


  # outputs_nodes_ips = module.infrastructure.xenorchestra_vm.vm[*].ipv4_addresses[0]
  # outputs_nodes = module.infrastructure.xenorchestra_vm.vm[*].name_label
  # outputs_masters_ips = module.infrastructure.xenorchestra_vm.vm_master[*].ipv4_addresses[0]
  # outputs_masters = module.infrastructure.xenorchestra_vm.vm_master[*].name_label
}