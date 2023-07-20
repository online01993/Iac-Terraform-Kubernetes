output "masters" {
  value = tomap({
    "fqdn"    = xenorchestra_vm.vm_master[*].name_label
	"address" = xenorchestra_vm.vm_master[*].ipv4_addresses[0]
  })
}
output "nodes" {
  value = tomap({
    "fqdn"    = xenorchestra_vm.vm[*].name_label
	"address" = xenorchestra_vm.vm[*].ipv4_addresses[0]
  })
}
output "vm_rsa_ssh_key_public" {
  value = "${tls_private_key.terrafrom_generated_private_key.public_key_openssh}"
} 
output "vm_rsa_ssh_key_private" {
  value = "${tls_private_key.terrafrom_generated_private_key.private_key_openssh}"  
  sensitive   = true
}  