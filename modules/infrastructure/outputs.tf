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
        "present" = true,
        "hostPath" = "/dev/xvdb",
        "volume"  = var.vm_storage_disk_size_gb * 1024 * 1024 * 1024
      })
      "nvme"   = ({
        "present" = true,
        "hostPath" = "/dev/xvdd",
        "volume"  = 0
      })
      "hdd"   = ({
        "present" = true,
        "hostPath" = "/dev/xvdc",
        "volume"  = 0
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