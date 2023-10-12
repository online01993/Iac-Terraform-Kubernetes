# output "masters" {
# value = tomap({
# "fqdn"    = xenorchestra_vm.vm_master[*].name_label
# "address" = xenorchestra_vm.vm_master[*].ipv4_addresses[0]
# })
# }
# output "nodes" {
# value = tomap({
# "fqdn"    = xenorchestra_vm.vm[*].name_label
# "address" = xenorchestra_vm.vm[*].ipv4_addresses[0]
# })
# }
output "masters" {
  value = [
    for i in range(length(xenorchestra_vm.vm_master)) :
    {
      "id"      = i
      "netbios" = "deb11-k8s-master-${i}-${random_uuid.vm_master_id[i].result}"
      "fqdn"    = xenorchestra_vm.vm_master[i].name_label
      "address" = xenorchestra_vm.vm_master[i].ipv4_addresses[0]
      
    }
  ]
}
output "nodes" {
  value = [
    for i in range(length(xenorchestra_vm.vm)) :
    {
      "id"      = i
      "netbios" = "deb11-k8s-worker-${i}-${random_uuid.vm_id[i].result}"
      "fqdn"    = xenorchestra_vm.vm[i].name_label
      "address" = xenorchestra_vm.vm[i].ipv4_addresses[0]
      "storage" = ({
      "ssd"   = ({
        "present" = fileexists("${path.module}/scripts/get_ssd_device_path_worker_${i}") ? true : false,
        #"present" = var.xen_infra_settings.node_storage_request.storage.ssd.count > 0 ? true : false,
        "hostPath" = fileexists("${path.module}/scripts/get_ssd_device_path_worker_${i}") ? file("${path.module}/scripts/get_ssd_device_path_worker_${i}") : "",
        #"hostPath" = var.xen_infra_settings.node_storage_request.storage.ssd.count > 0 ? var.xen_infra_settings.node_storage_request.storage.ssd.hostPath : "",
        "volume"  = fileexists("${path.module}/scripts/get_ssd_device_path_worker_${i}") ? var.xen_infra_settings.node_storage_request.storage.ssd.volume : 0
        #"volume"  = var.xen_infra_settings.node_storage_request.storage.ssd.count > 0 ? var.xen_infra_settings.node_storage_request.storage.ssd.volume : ""
      })
      "nvme"   = ({
        "present" = fileexists("${path.module}/scripts/get_nvme_device_path_worker_${i}") ? true : false,
        #"present" = var.xen_infra_settings.node_storage_request.storage.nvme.count > 0 ? true : false,
        "hostPath" = fileexists("${path.module}/scripts/get_nvme_device_path_worker_${i}") ? file("${path.module}/scripts/get_nvme_device_path_worker_${i}") : "",
        #"hostPath" = var.xen_infra_settings.node_storage_request.storage.nvme.count > 0 ? var.xen_infra_settings.node_storage_request.storage.nvme.hostPath : "",
        "volume"  = fileexists("${path.module}/scripts/get_nvme_device_path_worker_${i}") ? var.xen_infra_settings.node_storage_request.storage.nvme.volume : 0
        #"volume"  = var.xen_infra_settings.node_storage_request.storage.nvme.count > 0 ? var.xen_infra_settings.node_storage_request.storage.nvme.volume : ""
      })
      "hdd"   = ({
        "present" = fileexists("${path.module}/scripts/get_hdd_device_path_worker_${i}") ? true : false,
        #"present" = var.xen_infra_settings.node_storage_request.storage.hdd.count > 0 ? true : false,
        "hostPath" = fileexists("${path.module}/scripts/get_hdd_device_path_worker_${i}") ? file("${path.module}/scripts/get_hdd_device_path_worker_${i}") : "",
        #"hostPath" = var.xen_infra_settings.node_storage_request.storage.hdd.count > 0 ? var.xen_infra_settings.node_storage_request.storage.hdd.hostPath : "",
        "volume"  = fileexists("${path.module}/scripts/get_hdd_device_path_worker_${i}") ? var.xen_infra_settings.node_storage_request.storage.hdd.volume : 0
        #"volume"  = var.xen_infra_settings.node_storage_request.storage.hdd.count > 0 ? var.xen_infra_settings.node_storage_request.storage.hdd.volume : ""
      })
    })
    }
  ]
}
output "vm_rsa_ssh_key_public" {
  value = tls_private_key.terrafrom_generated_private_key.public_key_openssh
}
output "vm_rsa_ssh_key_private" {
  value     = tls_private_key.terrafrom_generated_private_key.private_key_openssh
  sensitive = true
}  