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
  value     = local.vm_rsa_ssh_key_private
  sensitive = true
}
output "k8s-url" {
  value     = module.kubernetes-base.k8s-url
}
output "k8s-endpont" {
  value     = module.kubernetes-base.k8s-endpont
}
output "k8s-admin_file" {
  value     = module.kubernetes-base.k8s-admin_file
  sensitive = true
}
output "k8s-client-key-data" {
  value     = module.kubernetes-base.k8s-client-key-data
  sensitive = true
}
output "k8s-client-certificate-data" {
  value     = module.kubernetes-base.k8s-client-certificate-data
  sensitive = true
}
output "k8s-certificate-authority-data" {
  value     = module.kubernetes-base.k8s-certificate-authority-data
  sensitive = true
}