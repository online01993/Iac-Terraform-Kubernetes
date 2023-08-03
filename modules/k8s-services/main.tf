#main.tf
resource "kubernetes_token_request_v1" "k8s_kube-token-default_resource" {
 depends_on                    = [kubectl_manifest.k8s_cni_plugin ]
 metadata {
    name      = "default"
  }
  spec {
    expiration_seconds = "8760h"
    audiences = [
      "api",
      "vault",
      "factors"
    ]
  }
}  