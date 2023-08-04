/*output "module_complete" {
  value = true
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_resource,
    data.local_sensitive_file.k8s-kubeadm_init_02_config_file,
    data.local_sensitive_file.k8s-kubeadm_init_02_config_get_client-key-data_file,
    data.local_sensitive_file.k8s-kubeadm_init_02_config_get_client-certificate-data_file,
    data.local_sensitive_file.k8s-kubeadm_init_02_config_get_certificate-authority-data_file,
    terraform_data.k8s-kubeadm-join_masters_04_resource,
    terraform_data.k8s-kubeadm-join_nodes_04_resource
  ]
}*/
output "k8s-url" {
  value = "https://${var.k8s_api_endpoint_ip}:${var.k8s_api_endpoint_port}"
}
output "k8s-endpont" {
  value = "${var.k8s_api_endpoint_ip}"
}
output "k8s-admin_file" {
  value = data.local_sensitive_file.k8s-kubeadm_init_02_config_file.content
  sensitive = true
}
output "k8s-client-key-data" {
  value = data.local_sensitive_file.k8s-kubeadm_init_02_config_get_client-key-data_file.content
  sensitive = true
}
output "k8s-client-certificate-data" {
  value = data.local_sensitive_file.k8s-kubeadm_init_02_config_get_client-certificate-data_file.content
  sensitive = true
}
output "k8s-certificate-authority-data" {
  value = data.local_sensitive_file.k8s-kubeadm_init_02_config_get_certificate-authority-data_file.content
  sensitive = true
}