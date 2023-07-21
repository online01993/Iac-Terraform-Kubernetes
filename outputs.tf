output "nodes" {
   value = module.infrastructure.nodes
}
output "masters" {
   value = module.infrastructure.masters
}
output "vm_rsa_ssh_key_public" {
  value = local.vm_rsa_ssh_key_public
}
output "vm_rsa_ssh_key_private" {
  value = local.vm_rsa_ssh_key_private
  sensitive   = true
}