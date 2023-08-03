#main.tf
resource "kubernetes_service_account_v1" "k8sadmin" {
  depends_on                   = [ kubectl_manifest.k8s_cni_plugin ]
  metadata {
    name = "k8sadmin"    
    #namespace = "default"
  }
}
resource "kubernetes_cluster_role_binding" "k8sadmin_role_bindings" {
  depends_on                   = [ 
    kubectl_manifest.k8s_cni_plugin,
    kubernetes_service_account_v1.k8sadmin
  ]
  metadata {
    name = "k8sadmin_role_bindings"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "User"
    name      = kubernetes_service_account_v1.k8sadmin.metadata.0.name
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.k8sadmin.metadata.0.name
    namespace = kubernetes_service_account_v1.k8sadmin.metadata.0.namespace
  }
  subject {
    kind      = "Group"
    name      = "system:masters"
    api_group = "rbac.authorization.k8s.io"
  }
}
resource "kubernetes_token_request_v1" "k8s_kube-token-k8sadmin_resource" {
 depends_on                    = [ kubectl_manifest.k8s_cni_plugin ]
 metadata {
    name  = kubernetes_service_account_v1.k8sadmin.metadata.0.name
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