output "k8s-api-endpont-url" {
  value = "https://${var.k8s_api_endpoint_ip}:${var.k8s_api_endpoint_port}"
}
output "k8s-endpont-ip" {
  value = var.k8s_api_endpoint_ip
}
output "k8s-admin_file" {
  value     = data.local_sensitive_file.k8s-kubeadm_init_02_config_file.content
  sensitive = true
}
output "k8s-client-key-data" {
  value     = data.local_sensitive_file.k8s-kubeadm_init_02_config_get_client-key-data_file.content
  sensitive = true
}
output "k8s-client-certificate-data" {
  value     = data.local_sensitive_file.k8s-kubeadm_init_02_config_get_client-certificate-data_file.content
  sensitive = true
}
output "k8s-certificate-authority-data" {
  value     = data.local_sensitive_file.k8s-kubeadm_init_02_config_get_certificate-authority-data_file.content
  sensitive = true
}
output "k8s_kube-token-k8sadmin" {
  value = nonsensitive(kubernetes_token_request_v1.k8s_kube-token-k8sadmin_resource.token)
}