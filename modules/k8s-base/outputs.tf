output "k8s-url" {
  value = "${var.k8s_api_endpoint_proto}://${var.k8s_api_endpoint_ip}:${var.k8s_api_endpoint_port}"
}
output "k8s-endpont" {
  value = "${var.k8s_api_endpoint_ip}"
}
output "k8s-admin_file" {
  value = data.local_sensitive_file.k8s-kubeadm_init_02_config_file.content
  sensitive = true
}