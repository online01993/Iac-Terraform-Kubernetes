#main.tf
resource "kubernetes_token_request_v1" "k8s_kube-token-default_resource" {
 depends_on                    = [kubectl_manifest.k8s_cni_plugin ]
 metadata {
    name      = "default"
  }
  spec {
    #5 years
    expiration_seconds = 157680000
    audiences = [
      "api",
      "vault",
      "factors",
      "https://kubernetes.default.svc.cluster.local"
    ]
  }
}  