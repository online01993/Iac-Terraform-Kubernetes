output "nodes" {
  value = module.infrastructure.nodes
}
output "masters" {
  value = module.infrastructure.masters
}
output "vm_rsa_ssh_key_public" {
  value     = module.infrastructure.vm_rsa_ssh_key_public
  sensitive = true
}
output "vm_rsa_ssh_key_private" {
  value     = module.infrastructure.vm_rsa_ssh_key_private
  sensitive = true
}
output "k8s-url" {
  value = module.kubernetes-base.k8s-url
}
output "k8s-endpont" {
  value = module.kubernetes-base.k8s-endpont
}
output "k8s_kube-token-k8sadmin" {
  value     = module.kubernetes-base.k8s_kube-token-k8sadmin
  sensitive = false
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