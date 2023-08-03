#outputs.tf
output "k8s_kube-token-default" {
  value     = nonsensitive(kubernetes_token_request_v1.k8s_kube-token-default_resource.token)
}