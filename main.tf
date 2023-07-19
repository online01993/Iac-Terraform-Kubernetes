resource "tls_private_key" "terrafrom_generated_private_key" {
   algorithm = "RSA"
   rsa_bits  = 4096
   provisioner "local-exec" {
    command = <<EOF
      mkdir -p .ssh-robot-access/
      cat <<< "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}" > .ssh-robot-access/robot_id_rsa.key
      cat <<< "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}" > .ssh-robot-access/robot_id_rsa.pub
      chmod 400 .ssh-robot-access/id_rsa.key
      chmod 400 .ssh-robot-access/id_rsa.key
    EOF
  }
   provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      rm -rvf .ssh-robot-access/
    EOF
  }
 }
module "infrastructure" {
  source = "./modules/infrastructure"
  #make linking vars from source and tfvars
  master_cpu_count         = var.global_master_cpu_count
  xen_network_name         = var.global_xen_network_name
  xen_vm_template_name     = var.global_xen_vm_template_name
  xen_pool_name            = var.global_xen_pool_name
  xen_xoa_url              = var.global_xen_xoa_url
  xen_xoa_username         = var.global_xen_xoa_username
  xen_xoa_password         = var.global_xen_xoa_password
  xen_xoa_insecure         = var.global_xen_xoa_insecure
  node_count               = var.global_node_count
  master_count             = var.global_master_node_high_availability == true ? 3 : 1
  master_disk_size_gb      = var.global_master_disk_size_gb
  vm_disk_size_gb          = var.global_vm_disk_size_gb
  master_memory_size_gb    = var.global_master_memory_size_gb
  #vm_rsa_ssh_key           = var.global_vm_rsa_ssh_key
  vm_rsa_ssh_key           = "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}"
  xen_sr_id                = var.global_xen_sr_id
  xen_large_sr_id          = var.global_xen_large_sr_id
  master_labels            = var.global_master_labels
  node_labels              = var.global_node_labels
  master_vm_tags           = var.global_master_vm_tags
  node_vm_tags             = var.global_node_vm_tags
  certificate_params       = var.global_certificate_params
  vm_storage_disk_size_gb  = var.global_vm_storage_disk_size_gb
  dns_key_name             = var.global_dns_key_name
  dns_key_secret           = var.global_dns_key_secret
  vm_memory_size_gb        = var.global_vm_memory_size_gb
  vm_cpu_count             = var.global_vm_cpu_count
  dns_server               = var.global_dns_server
  dns_zone                 = var.global_dns_zone
  dns_sub_zone             = var.global_dns_sub_zone
  master_node_address_mask = var.global_master_node_address_mask
  worker_node_address_mask = var.global_worker_node_address_mask
  nodes_mask               = var.global_nodes_mask
  nodes_gateway            = var.global_nodes_gateway
  nodes_dns_address        = var.global_nodes_dns_address
  master_node_network_dhcp = var.global_master_node_network_dhcp
  worker_node_network_dhcp = var.global_worker_node_network_dhcp
}
module "kubernetes" {
  depends_on = [ module.infrastructure ]
  source = "./modules/k8s"
  #vm_rsa_ssh_key           = var.global_vm_rsa_ssh_key
  vm_rsa_ssh_key_private    = "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}"
  masters = module.infrastructure.masters
  nodes = module.infrastructure.nodes
  version_containerd = var.global_version_containerd
  version_runc = var.global_version_runc
  version_cni-plugin = var.global_version_cni-plugin
}