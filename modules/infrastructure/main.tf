#vm.tf
data "xenorchestra_pool" "pool" {
  name_label = var.xen_pool_name
}
data "xenorchestra_hosts" "all_hosts" {
  pool_id    = data.xenorchestra_pool.pool.id
  sort_by    = "name_label"
  sort_order = "asc"
}
data "xenorchestra_network" "net" {
  name_label = var.xen_network_name
  pool_id    = data.xenorchestra_pool.pool.id
}
data "xenorchestra_template" "vm" {
  name_label = var.xen_vm_template_name
}
resource "random_uuid" "vm_id" {
  count = var.node_count
}
resource "random_uuid" "vm_master_id" {
  count = var.master_count
}
resource "xenorchestra_cloud_config" "bar_vm_master" {
  count = var.master_count
  name  = "debian-base-config-master-${count.index}"
  template = templatefile("./modules/infrastructure/cloud_config.tftpl", {
    hostname       = "deb11-k8s-${random_uuid.vm_master_id[count.index].result}.${lower(var.dns_sub_zone)}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
    vm_rsa_ssh_key = "${var.vm_rsa_ssh_key}"
  })
}
resource "xenorchestra_cloud_config" "cloud_network_config_masters" {
  count = var.master_count
  name  = "debian-network-base-config-master-${count.index}"
  #template = "./modules/infrastructure/cloud_network_dhcp.yaml"
  template = templatefile("./modules/infrastructure/cloud_network_static.yaml", {
    node_address   = "${var.master_node_address_mask}${count.index + 2}"
    node_mask      = "${var.nodes_mask}"
    node_gateway   = "${var.nodes_gateway}"
	node_dns_address = "${var.nodes_dns_address}"
    node_dns_search = "${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  })
}
# data "local_file" "cloud_network_config_masters" {
  # count = var.master_count
  # #filename = "./modules/infrastructure/cloud_network_dhcp.yaml"
  # filename = "./modules/infrastructure/cloud_network_static.yaml"
  # content = templatefile("./modules/infrastructure/cloud_network_static.yaml", {
    # node_address   = "${var.master_node_address_mask}${count.index + 2}"
    # node_mask      = "${var.nodes_mask}"
    # node_gateway   = "${var.nodes_gateway}"
	# node_dns_address = "${var.nodes_dns_address}"
    # node_dns_search = "${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  # })
# }
resource "xenorchestra_cloud_config" "bar_vm" {
  count = var.node_count
  name  = "debian-base-config-node-${count.index}"
  template = templatefile("./modules/infrastructure/cloud_config.tftpl", {
    hostname       = "deb11-k8s-${random_uuid.vm_id[count.index].result}.${lower(var.dns_sub_zone)}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
    vm_rsa_ssh_key = "${var.vm_rsa_ssh_key}"
  })
}
resource "xenorchestra_cloud_config" "cloud_network_config_workers" {
  count = var.node_count
  name  = "debian-network-base-config-node-${count.index}"
  #template = "./modules/infrastructure/cloud_network_dhcp.yaml"
  template = templatefile("./modules/infrastructure/cloud_network_static.yaml", {
    node_address   = "${var.worker_node_address_mask}${count.index + 1}"
    node_mask      = "${var.nodes_mask}"
    node_gateway   = "${var.nodes_gateway}"
	node_dns_address = "${var.nodes_dns_address}"
    node_dns_search = "${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  })
}
# data "local_file" "cloud_network_config_workers" {
  # count = var.node_count
  # #filename = "./modules/infrastructure/cloud_network_dhcp.yaml"
  # filename = "./modules/infrastructure/cloud_network_static.yaml"
  # content = templatefile("./modules/infrastructure/cloud_network_static.yaml", {
    # node_address   = "${var.worker_node_address_mask}${count.index + 1}"
    # node_mask      = "${var.nodes_mask}"
    # node_gateway   = "${var.nodes_gateway}"
	# node_dns_address = "${var.nodes_dns_address}"
    # node_dns_search = "${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  # })
# }
resource "xenorchestra_vm" "vm_master" {
  count                = var.master_count
  name_label           = "deb11-k8s-master-${random_uuid.vm_master_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm_master[count.index].template
  #cloud_network_config = data.local_file.cloud_network_config_masters[count.index].content
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_masters[count.index].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  disk {
    sr_id      = var.xen_sr_id[count.index % length(var.xen_sr_id)]
    name_label = "deb11-k8s-master-${random_uuid.vm_master_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}--system"
    size       = var.master_disk_size_gb * 1024 * 1024 * 1024 # GB to B
  }
  cpus          = var.master_cpu_count
  memory_max    = var.master_memory_size_gb * 1024 * 1024 * 1024 # GB to B
  wait_for_ip   = true
  tags          = concat(var.master_vm_tags, ["ntmax.ca/cloud-os:debian-11-focal", "ntmax.ca/failure-domain:${count.index % length(data.xenorchestra_hosts.all_hosts.hosts)}"])
  affinity_host = data.xenorchestra_hosts.all_hosts.hosts[count.index % length(data.xenorchestra_hosts.all_hosts.hosts)].id
  lifecycle {
    ignore_changes = [disk, affinity_host, template]
  }
  timeouts {
    create = "20m"
  }
}
resource "xenorchestra_vm" "vm" {
  count                = var.node_count
  name_label           = "deb11-k8s-node-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm[count.index].template
  #cloud_network_config = data.local_file.cloud_network_config_workers[count.index].content
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_workers[count.index].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  disk {
    sr_id      = var.xen_sr_id[count.index % length(var.xen_sr_id)]
    name_label = "deb11-k8s-node-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}--system"
    size       = var.vm_disk_size_gb * 1024 * 1024 * 1024 # GB to B
  }
  disk {
    sr_id      = var.xen_large_sr_id[count.index % length(var.xen_large_sr_id)]
    name_label = "deb11-k8s-node-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}--kubernetes-data"
    size       = var.vm_storage_disk_size_gb * 1024 * 1024 * 1024 # GB to B
  }
  cpus          = var.master_cpu_count
  memory_max    = var.master_memory_size_gb * 1024 * 1024 * 1024 # GB to B
  wait_for_ip   = true
  tags          = concat(var.node_vm_tags, ["ntmax.ca/cloud-os:debian-11-focal", "ntmax.ca/failure-domain:${count.index % length(data.xenorchestra_hosts.all_hosts.hosts)}"])
  affinity_host = data.xenorchestra_hosts.all_hosts.hosts[count.index % length(data.xenorchestra_hosts.all_hosts.hosts)].id
  lifecycle {
    ignore_changes = [disk, template]
  }
  timeouts {
    create = "20m"
  }
}