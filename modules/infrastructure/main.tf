#main.tf
resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  provisioner "local-exec" {
    command = <<EOF
      mkdir -p .ssh-robot-access/
      echo "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}" > .ssh-robot-access/robot_id_rsa.key
      echo "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}" > .ssh-robot-access/robot_id_rsa.pub
      chmod 400 .ssh-robot-access/robot_id_rsa.key
      chmod 400 .ssh-robot-access/robot_id_rsa.pub
    EOF
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      rm -rvf .ssh-robot-access/
    EOF
  }
}
data "xenorchestra_pool" "pool" {
  name_label = var.xen_infra_settings.xen_servers_settings.xen_pool_name
}
data "xenorchestra_hosts" "all_hosts" {
  pool_id    = data.xenorchestra_pool.pool.id
  sort_by    = "name_label"
  sort_order = "asc"
}
data "xenorchestra_network" "net" {
  name_label = var.xen_infra_settings.xen_servers_settings.xen_network_name
  pool_id    = data.xenorchestra_pool.pool.id
}
data "xenorchestra_template" "vm" {
  name_label = var.xen_infra_settings.xen_servers_settings.xen_vm_template_name
}
resource "random_uuid" "vm_master_id" {
  for_each = range(0,3)
}
resource "random_uuid" "vm_id" {
  for_each = range(0, var.xen_infra_settings.worker_vm_request.vm_settings.count - 1)
}
resource "xenorchestra_cloud_config" "bar_vm_master" {
  depends_on = [
    tls_private_key.terrafrom_generated_private_key
  ]
  for_each = range(0, var.xen_infra_settings.master_vm_request.vm_settings.count - 1)
  name  = "debian-base-config-master-${each.key}"
  template = templatefile("${path.module}/cloud_config.tftpl", {
    hostname       = "deb11-k8s-master-${each.key}-${random_uuid.vm_master_id[each.key].result}.${lower(var.xen_infra_settings.dns_request.dns_sub_zone)}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
    vm_rsa_ssh_key = "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}"
  })
}
resource "xenorchestra_cloud_config" "cloud_network_config_masters" {
  for_each = range(0, var.xen_infra_settings.master_vm_request.vm_settings.count - 1)
  name  = "debian-network-base-config-master-${each.key}"
  #template = "cloud_network_dhcp.yaml"
  template = var.xen_infra_settings.master_vm_request.network_settings.node_network_dhcp == false ? templatefile("${path.module}/cloud_network_static.yaml", {
    node_address     = "${var.xen_infra_settings.master_vm_request.network_settings.node_address_mask}${each.key + var.xen_infra_settings.master_vm_request.network_settings.node_address_start_ip}"
    node_mask        = "${var.xen_infra_settings.master_vm_request.network_settings.nodes_mask}"
    node_gateway     = "${var.xen_infra_settings.master_vm_request.network_settings.nodes_gateway}"
    node_dns_address = "${var.xen_infra_settings.master_vm_request.network_settings.nodes_dns_address}"
    node_dns_search  = "${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  }) : templatefile("${path.module}/cloud_network_dhcp.yaml", {})
}
resource "xenorchestra_cloud_config" "bar_vm" {
  depends_on = [
    tls_private_key.terrafrom_generated_private_key
  ]
  for_each = range(0, var.xen_infra_settings.worker_vm_request.vm_settings.count - 1)
  name  = "debian-base-config-node-${each.key}"
  template = templatefile("${path.module}/cloud_config.tftpl", {
    hostname       = "deb11-k8s-worker-${each.key}-${random_uuid.vm_id[each.key].result}.${lower(var.xen_infra_settings.dns_request.dns_sub_zone)}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
    vm_rsa_ssh_key = "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}"
  })
}
resource "xenorchestra_cloud_config" "cloud_network_config_workers" {
  for_each = range(0, var.xen_infra_settings.worker_vm_request.vm_settings.count - 1)
  name  = "debian-network-base-config-node-${each.key}"
  #template = "cloud_network_dhcp.yaml"
  template = var.xen_infra_settings.worker_vm_request.network_settings.node_network_dhcp == false ? templatefile("${path.module}/cloud_network_static.yaml", {
    node_address     = "${var.xen_infra_settings.worker_vm_request.network_settings.node_address_mask}${each.key + var.xen_infra_settings.worker_vm_request.network_settings.node_address_start_ip}"
    node_mask        = "${var.xen_infra_settings.worker_vm_request.network_settings.nodes_mask}"
    node_gateway     = "${var.xen_infra_settings.worker_vm_request.network_settings.nodes_gateway}"
    node_dns_address = "${var.xen_infra_settings.worker_vm_request.network_settings.nodes_dns_address}"
    node_dns_search  = "${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  }) : templatefile("${path.module}/cloud_network_dhcp.yaml", {})
}
/* resource "xenorchestra_vm" "vm_master" {
  count                = var.master_count
  name_label           = "deb11-k8s-master-${count.index}-${random_uuid.vm_master_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm_master[count.index].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_masters[count.index].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  disk {
    sr_id      = var.xen_sr_id[count.index % length(var.xen_sr_id)]
    name_label = "deb11-k8s-master-${count.index}-${random_uuid.vm_master_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}--system"
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
} */
/* resource "xenorchestra_vm" "vm" {
  count                = var.node_count
  name_label           = "deb11-k8s-worker-${count.index}-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm[count.index].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_workers[count.index].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  disk {
    sr_id      = var.xen_sr_id[count.index % length(var.xen_sr_id)]
    name_label = "deb11-k8s-worker-${count.index}-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}--system"
    size       = var.vm_disk_size_gb * 1024 * 1024 * 1024 # GB to B
  }
  disk {
    sr_id      = var.xen_large_sr_id[count.index % length(var.xen_large_sr_id)]
    name_label = "deb11-k8s-worker-${count.index}-${random_uuid.vm_id[count.index].result}.${var.dns_sub_zone}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}--kubernetes-data"
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
  #depends_on = [
  #  xenorchestra_vm.vm_master
  #]
} */
resource "xenorchestra_vm" "vm_master" {
  for_each = range(0, var.xen_infra_settings.master_vm_request.vm_settings.count - 1)
  name_label           = "deb11-k8s-master-${each.key}-${random_uuid.vm_master_id[each.key].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm_master[each.key].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_masters[each.key].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  #System disk
  disk {
    sr_id      = var.xen_infra_settings.node_storage_request.storage.system.sr_ids[each.key % length(var.xen_infra_settings.node_storage_request.storage.system.sr_ids)]
    name_label = "deb11-k8s-master-${each.key}-${random_uuid.vm_master_id[each.key].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--system"
    size       = var.xen_infra_settings.node_storage_request.storage.system.volume
  }
  cpus          = var.xen_infra_settings.master_vm_request.vm_settings.cpu_count
  memory_max    = var.xen_infra_settings.master_vm_request.vm_settings.memory_size_gb * 1024 * 1024 * 1024 # GB to B
  wait_for_ip   = true
  tags          = concat(var.xen_infra_settings.master_vm_request.vm_settings.vm_tags, ["ntmax.ca/cloud-os:debian-11-focal", "ntmax.ca/failure-domain:${each.key % length(data.xenorchestra_hosts.all_hosts.hosts)}"])
  affinity_host = data.xenorchestra_hosts.all_hosts.hosts[each.key % length(data.xenorchestra_hosts.all_hosts.hosts)].id
  lifecycle {
    ignore_changes = [disk, affinity_host, template]
  }
  timeouts {
    create = "20m"
  }
}
resource "xenorchestra_vm" "vm" {
  for_each = range(0, var.xen_infra_settings.worker_vm_request.vm_settings.count - 1)
  name_label           = "deb11-k8s-worker-${each.key}-${random_uuid.vm_id[each.key].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm[each.key].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_workers[each.key].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  #System disk
  disk {
    sr_id      = var.xen_infra_settings.node_storage_request.storage.system.sr_ids[each.key % length(var.xen_infra_settings.node_storage_request.storage.system.sr_ids)]
    name_label = "deb11-k8s-worker-${each.key}-${random_uuid.vm_id[each.key].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--system"
    size       = var.xen_infra_settings.node_storage_request.storage.system.volume
  }
  #Dynamic SSD disk
  dynamic "disk" {
    for_each = each.key <= (var.xen_infra_settings.node_storage_request.storage.ssd.count - 1) ? range(0, 1) : []
    content {
        sr_id = var.xen_infra_settings.node_storage_request.storage.ssd.sr_ids[each.key % length(var.xen_infra_settings.node_storage_request.storage.ssd.sr_ids)]
        name_label = "deb11-k8s-worker-${each.key}-${random_uuid.vm_id[each.key].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--ssd-data"
        size  = var.xen_infra_settings.node_storage_request.storage.ssd.volume
      }
  }
  #Dynamic NVMe disk
  dynamic "disk" {
    for_each = each.key <= (var.xen_infra_settings.node_storage_request.storage.nvme.count - 1) ? range(0, 1) : []
    content {
        sr_id = var.xen_infra_settings.node_storage_request.storage.nvme.sr_ids[each.key % length(var.xen_infra_settings.node_storage_request.storage.nvme.sr_ids)]
        name_label = "deb11-k8s-worker-${each.key}-${random_uuid.vm_id[each.key].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--nvme-data"
        size  = var.xen_infra_settings.node_storage_request.storage.nvme.volume
      }
  }
 #Dynamic HDD disk
  dynamic "disk" {
    for_each = each.key <= (var.xen_infra_settings.node_storage_request.storage.hdd.count - 1) ? range(0, 1) : []
    content {
        sr_id = var.xen_infra_settings.node_storage_request.storage.hdd.sr_ids[each.key % length(var.xen_infra_settings.node_storage_request.storage.hdd.sr_ids)]
        name_label = "deb11-k8s-worker-${each.key}-${random_uuid.vm_id[each.key].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--hdd-data"
        size  = var.xen_infra_settings.node_storage_request.storage.hdd.volume
      }
  }
  cpus          = var.xen_infra_settings.worker_vm_request.vm_settings.cpu_count
  memory_max    = var.xen_infra_settings.worker_vm_request.vm_settings.memory_size_gb * 1024 * 1024 * 1024 # GB to B
  wait_for_ip   = true
  tags          = concat(var.xen_infra_settings.worker_vm_request.vm_settings.vm_tags, ["ntmax.ca/cloud-os:debian-11-focal", "ntmax.ca/failure-domain:${each.key % length(data.xenorchestra_hosts.all_hosts.hosts)}"])
  affinity_host = data.xenorchestra_hosts.all_hosts.hosts[each.key % length(data.xenorchestra_hosts.all_hosts.hosts)].id
  lifecycle {
    ignore_changes = [disk, affinity_host, template]
  }
  timeouts {
    create = "20m"
  }
}