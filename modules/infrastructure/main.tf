#main.tf
resource "tls_private_key" "terrafrom_generated_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  provisioner "local-exec" {
    command = <<EOF
      mkdir -p ${path.module}/scripts/.ssh-robot-access/
      echo "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}" > ${path.module}/scripts/.ssh-robot-access/robot_id_rsa.key
      echo "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}" > ${path.module}/scripts/.ssh-robot-access/robot_id_rsa.pub
      chmod 400 ${path.module}/scripts/.ssh-robot-access/robot_id_rsa.key
      chmod 400 ${path.module}/scripts/.ssh-robot-access/robot_id_rsa.pub
    EOF
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      rm -rvf ${path.module}/scripts/.ssh-robot-access/
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
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.master_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
}
resource "random_uuid" "vm_id" {
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
}
resource "xenorchestra_cloud_config" "bar_vm_master" {
  depends_on = [
    tls_private_key.terrafrom_generated_private_key
  ]
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.master_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  name  = "${var.xen_infra_settings.master_vm_request.vm_settings.name_label_prefix}-cloud_config-${each.value.id}"
  template = templatefile("${path.module}/scripts/cloud_config.tftpl", {
    hostname       = "${var.xen_infra_settings.master_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_master_id[each.value.id].result}.${lower(var.xen_infra_settings.dns_request.dns_sub_zone)}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
    vm_rsa_ssh_key = "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}"
  })
}
resource "xenorchestra_cloud_config" "cloud_network_config_masters" {
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.master_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  name  = "${var.xen_infra_settings.master_vm_request.vm_settings.name_label_prefix}-cloud_config_network-${each.value.id}"
  template = var.xen_infra_settings.master_vm_request.network_settings.node_network_dhcp == false ? templatefile("${path.module}/scripts/cloud_network_static.yaml", {
    node_address     = "${var.xen_infra_settings.master_vm_request.network_settings.node_address_mask}${each.value.id + var.xen_infra_settings.master_vm_request.network_settings.node_address_start_ip}"
    node_mask        = "${var.xen_infra_settings.master_vm_request.network_settings.nodes_mask}"
    node_gateway     = "${var.xen_infra_settings.master_vm_request.network_settings.nodes_gateway}"
    node_dns_address = "${var.xen_infra_settings.master_vm_request.network_settings.nodes_dns_address}"
    node_dns_search  = "${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  }) : templatefile("${path.module}/scripts/cloud_network_dhcp.yaml", {})
}
resource "xenorchestra_cloud_config" "bar_vm" {
  depends_on = [
    tls_private_key.terrafrom_generated_private_key
  ]
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  name  = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-cloud_config-${each.value.id}"
  template = templatefile("${path.module}/scripts/cloud_config.tftpl", {
    hostname       = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_id[each.value.id].result}.${lower(var.xen_infra_settings.dns_request.dns_sub_zone)}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
    vm_rsa_ssh_key = "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}"
  })
}
resource "xenorchestra_cloud_config" "cloud_network_config_workers" {
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  name  = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-cloud_config_network-${each.value.id}"
  template = var.xen_infra_settings.worker_vm_request.network_settings.node_network_dhcp == false ? templatefile("${path.module}/scripts/cloud_network_static.yaml", {
    node_address     = "${var.xen_infra_settings.worker_vm_request.network_settings.node_address_mask}${each.value.id + var.xen_infra_settings.worker_vm_request.network_settings.node_address_start_ip}"
    node_mask        = "${var.xen_infra_settings.worker_vm_request.network_settings.nodes_mask}"
    node_gateway     = "${var.xen_infra_settings.worker_vm_request.network_settings.nodes_gateway}"
    node_dns_address = "${var.xen_infra_settings.worker_vm_request.network_settings.nodes_dns_address}"
    node_dns_search  = "${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  }) : templatefile("${path.module}/scripts/cloud_network_dhcp.yaml", {})
}
resource "xenorchestra_vm" "vm_master" {
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.master_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  name_label           = "${var.xen_infra_settings.master_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_master_id[each.value.id].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm_master[each.value.id].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_masters[each.value.id].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  #System disk
  disk {
    sr_id      = var.xen_infra_settings.node_storage_request.storage.system.sr_ids[each.value.id % length(var.xen_infra_settings.node_storage_request.storage.system.sr_ids)]
    name_label = "${var.xen_infra_settings.master_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_master_id[each.value.id].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--system"
    size       = var.xen_infra_settings.node_storage_request.storage.system.volume
  }
  cpus          = var.xen_infra_settings.master_vm_request.vm_settings.cpu_count
  memory_max    = var.xen_infra_settings.master_vm_request.vm_settings.memory_size_gb
  wait_for_ip   = true
  tags          = concat(var.xen_infra_settings.master_vm_request.vm_settings.vm_tags, ["ntmax.ca/cloud-os:debian-11-focal", "ntmax.ca/failure-domain:${each.value.id % length(data.xenorchestra_hosts.all_hosts.hosts)}"])
  affinity_host = data.xenorchestra_hosts.all_hosts.hosts[each.value.id % length(data.xenorchestra_hosts.all_hosts.hosts)].id
  lifecycle {
    ignore_changes = [disk, affinity_host, template]
  }
  timeouts {
    create = "20m"
  }
}
resource "xenorchestra_vm" "vm" {
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  name_label           = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_id[each.value.id].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}"
  cloud_config         = xenorchestra_cloud_config.bar_vm[each.value.id].template
  cloud_network_config = xenorchestra_cloud_config.cloud_network_config_workers[each.value.id].template
  template             = data.xenorchestra_template.vm.id
  auto_poweron         = true
  network {
    network_id = data.xenorchestra_network.net.id
  }
  #System disk
  disk {
    sr_id      = var.xen_infra_settings.node_storage_request.storage.system.sr_ids[each.value.id % length(var.xen_infra_settings.node_storage_request.storage.system.sr_ids)]
    name_label = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_id[each.value.id].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--system"
    size       = var.xen_infra_settings.node_storage_request.storage.system.volume
  }
  #Dynamic SSD disk
  dynamic "disk" {
    for_each = each.value.id <= (var.xen_infra_settings.node_storage_request.storage.ssd.count - 1) ? range(0, 1) : []
    content {
        sr_id = var.xen_infra_settings.node_storage_request.storage.ssd.sr_ids[each.value.id % length(var.xen_infra_settings.node_storage_request.storage.ssd.sr_ids)]
        name_label = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_id[each.value.id].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--ssd-data"
        size  = var.xen_infra_settings.node_storage_request.storage.ssd.volume
      }
  }
  #Dynamic NVMe disk
  dynamic "disk" {
    for_each = each.value.id <= (var.xen_infra_settings.node_storage_request.storage.nvme.count - 1) ? range(0, 1) : []
    content {
        sr_id = var.xen_infra_settings.node_storage_request.storage.nvme.sr_ids[each.value.id % length(var.xen_infra_settings.node_storage_request.storage.nvme.sr_ids)]
        name_label = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_id[each.value.id].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--nvme-data"
        size  = var.xen_infra_settings.node_storage_request.storage.nvme.volume
      }
  }
 #Dynamic HDD disk
  dynamic "disk" {
    for_each = each.value.id <= (var.xen_infra_settings.node_storage_request.storage.hdd.count - 1) ? range(0, 1) : []
    content {
        sr_id = var.xen_infra_settings.node_storage_request.storage.hdd.sr_ids[each.value.id % length(var.xen_infra_settings.node_storage_request.storage.hdd.sr_ids)]
        name_label = "${var.xen_infra_settings.worker_vm_request.vm_settings.name_label_prefix}-${each.value.id}-${random_uuid.vm_id[each.value.id].result}.${var.xen_infra_settings.dns_request.dns_sub_zone}.${substr(lower(var.xen_infra_settings.dns_request.dns_zone), 0, length(var.xen_infra_settings.dns_request.dns_zone) - 1)}--hdd-data"
        size  = var.xen_infra_settings.node_storage_request.storage.hdd.volume
      }
  }
  cpus          = var.xen_infra_settings.worker_vm_request.vm_settings.cpu_count
  memory_max    = var.xen_infra_settings.worker_vm_request.vm_settings.memory_size_gb
  wait_for_ip   = true
  tags          = concat(var.xen_infra_settings.worker_vm_request.vm_settings.vm_tags, ["ntmax.ca/cloud-os:debian-11-focal", "ntmax.ca/failure-domain:${each.value.id % length(data.xenorchestra_hosts.all_hosts.hosts)}"])
  affinity_host = data.xenorchestra_hosts.all_hosts.hosts[each.value.id % length(data.xenorchestra_hosts.all_hosts.hosts)].id
  lifecycle {
    ignore_changes = [disk, affinity_host, template]
  }
  timeouts {
    create = "20m"
  }
}
#####
resource "terraform_data" "get_device_path_workers" {
  depends_on = [
    xenorchestra_vm.vm
  ]
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  connection {
    type        = "ssh"
    user        = "robot"
    private_key = tls_private_key.terrafrom_generated_private_key.private_key_openssh
    #host        = each.value.ipv4_addresses[0]
    host        = xenorchestra_vm.vm[each.value.id].ipv4_addresses[0]
  }
  provisioner "remote-exec" {
    inline = [<<EOF
      #cloud-init-wait 
      while [ ! -f /var/lib/cloud/instance/boot-finished ]; do 
      echo -e "\033[1;36mWaiting for cloud-init..."
      sleep 10
      done
      EOF
    ]
  }
  provisioner "local-exec" {
    command = <<EOF
      echo "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}" > ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      chmod 600 ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      ssh -o StrictHostKeyChecking=no -i ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key -o ConnectTimeout=2 robot@${xenorchestra_vm.vm[each.value.id].ipv4_addresses[0]} '(sleep 2; sudo reboot)&'; sleep 5      
      until ssh -o StrictHostKeyChecking=no -i ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key -o ConnectTimeout=2 robot@${xenorchestra_vm.vm[each.value.id].ipv4_addresses[0]} true 2> /dev/null
      do
        echo "Waiting for OS to reboot and become available..."
        sleep 3
      done
      rm -rvf ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
    EOF
  }
  #SSD
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/get_ssd_device_path_worker_${each.value.id}
      echo "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}" > ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      chmod 600 ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      ssh robot@${xenorchestra_vm.vm[each.value.id].ipv4_addresses[0]} -o StrictHostKeyChecking=no -i ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key "sudo fdisk -l | grep ${var.xen_infra_settings.node_storage_request.storage.ssd.volume} | awk '{print $2}' | tr -d :" > ${path.module}/scripts/get_ssd_device_path_worker_${each.value.id}
      rm -rvf ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
    EOF
  }
  #NVMe
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/get_nvme_device_path_worker_${each.value.id}
      echo "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}" > ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      chmod 600 ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      ssh robot@${xenorchestra_vm.vm[each.value.id].ipv4_addresses[0]} -o StrictHostKeyChecking=no -i ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key "sudo fdisk -l | grep ${var.xen_infra_settings.node_storage_request.storage.nvme.volume} | awk '{print $2}' | tr -d :" > ${path.module}/scripts/get_nvme_device_path_worker_${each.value.id}
      rm -rvf ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
    EOF
  }
  #HDD
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/get_hdd_device_path_worker_${each.value.id}
      echo "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}" > ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      chmod 600 ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
      ssh robot@${xenorchestra_vm.vm[each.value.id].ipv4_addresses[0]} -o StrictHostKeyChecking=no -i ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key "sudo fdisk -l | grep ${var.xen_infra_settings.node_storage_request.storage.hdd.volume} | awk '{print $2}' | tr -d :" > ${path.module}/scripts/get_hdd_device_path_worker_${each.value.id}
      rm -rvf ${path.module}/scripts/.robot_id_rsa_worker_${each.value.id}.key
    EOF
  }
}
/* data "local_file" "disk_ssd_path_workers" {
  depends_on = [
    terraform_data.get_device_path_workers
  ]
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  filename = "${path.module}/scripts/get_ssd_device_path_worker_${each.value.id}"
}
data "local_file" "disk_nvme_path_workers" {
  depends_on = [
    terraform_data.get_device_path_workers
  ]
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  filename = "${path.module}/scripts/get_nvme_device_path_worker_${each.value.id}"
}
data "local_file" "disk_hdd_path_workers" {
  depends_on = [
    terraform_data.get_device_path_workers
  ]
  for_each = { 
    for i in toset([ 
      for index, i in range(0,var.xen_infra_settings.worker_vm_request.vm_settings.count) : {
        "id" = index
      } 
    ]) : i.id => i 
  }
  filename = "${path.module}/scripts/get_hdd_device_path_worker_${each.value.id}"
} */