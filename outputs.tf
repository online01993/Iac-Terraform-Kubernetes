output "nodes" {
  value = module.infrastructure.xen_nodes
}
output "masters" {
  value = module.infrastructure.xen_masters
}
output "vm_rsa_ssh_key_public" {
  value     = module.infrastructure.vm_rsa_ssh_key_public
  sensitive = true
}
output "vm_rsa_ssh_key_private" {
  value     = module.infrastructure.vm_rsa_ssh_key_private
  sensitive = true
}
output "k8s-api-endpont-url" {
  value = module.kubernetes-base.k8s-api-endpont-url
}
output "k8s-endpont-ip" {
  value = module.kubernetes-base.k8s-endpont-ip
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
/* output "k8s_kube-token-k8sadmin" {
  value     = module.k8s-system-services.k8s_kube-token-k8sadmin
  sensitive = false
}
output "nodes_with_storage_available" {
  value     = module.k8s-system-services.nodes_with_storage_available
}
output "storage_available" {
  value     = module.k8s-system-services.storage_available
} */