#kube-dashboard.tf
#https://adamtheautomator.com/kubernetes-dashboard/
##kubectl provider solution
/*resource "kubectl_manifest" "k8s_kube-dashboard" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = {
    for i in toset([
      for index, i in (split("---", templatefile("${path.module}/scripts/kube-dashboard.yml.tpl", {
        kube-dashboard_nodePort = "${var.kube-dashboard_nodePort}"
        })
      )) :
      {
        "id"  = index
        "doc" = i
      }
      #if try(yamldecode(i).metadata.name, "") != ""
    ])
    : i.id => i
  }
  yaml_body = each.value.doc
}*/
#k2tf converter to kubernetes provider solution
resource "kubernetes_namespace" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  metadata {
    name = "kubernetes-dashboard"
  }
}
resource "kubernetes_service_account" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard
  ]
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
}
resource "kubernetes_service" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard
  ]
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  spec {
    port {
      port        = 443
      target_port = 8443
      node_port   = var.kube-dashboard_nodePort
    }
    selector = {
      k8s-app = "kubernetes-dashboard"
    }
    type = "NodePort"
  }
}
resource "kubernetes_secret" "kubernetes_dashboard_certs" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard
  ]
  metadata {
    name      = "kubernetes-dashboard-certs"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  type = "Opaque"
}
resource "kubernetes_secret" "kubernetes_dashboard_csrf" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard
  ]
  metadata {
    name      = "kubernetes-dashboard-csrf"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  type = "Opaque"
}
resource "kubernetes_secret" "kubernetes_dashboard_key_holder" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard
  ]
  metadata {
    name      = "kubernetes-dashboard-key-holder"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  type = "Opaque"
}
resource "kubernetes_config_map" "kubernetes_dashboard_settings" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard
  ]
  metadata {
    name      = "kubernetes-dashboard-settings"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
}
resource "kubernetes_role" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard,
    kubernetes_secret.kubernetes_dashboard_certs,
    kubernetes_secret.kubernetes_dashboard_csrf,
    kubernetes_secret.kubernetes_dashboard_key_holder,
    kubernetes_config_map.kubernetes_dashboard_settings,
    kubernetes_service.dashboard_metrics_scraper
  ]
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  rule {
    verbs          = ["get", "update", "delete"]
    api_groups     = [""]
    resources      = ["secrets"]
    resource_names = ["kubernetes-dashboard-key-holder", "kubernetes-dashboard-certs", "kubernetes-dashboard-csrf"]
  }
  rule {
    verbs          = ["get", "update"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["kubernetes-dashboard-settings"]
  }
  rule {
    verbs          = ["proxy"]
    api_groups     = [""]
    resources      = ["services"]
    resource_names = ["heapster", "dashboard-metrics-scraper"]
  }
  rule {
    verbs          = ["get"]
    api_groups     = [""]
    resources      = ["services/proxy"]
    resource_names = ["heapster", "http:heapster:", "https:heapster:", "dashboard-metrics-scraper", "http:dashboard-metrics-scraper"]
  }
}
resource "kubernetes_cluster_role" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard
  ]
  metadata {
    name = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
  }
}
resource "kubernetes_role_binding" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard,
    kubernetes_role.kubernetes_dashboard
  ]
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "kubernetes-dashboard"
  }
}
resource "kubernetes_cluster_role_binding" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard,
    kubernetes_cluster_role.kubernetes_dashboard
  ]
  metadata {
    name = "kubernetes-dashboard"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "kubernetes-dashboard"
  }
}
resource "kubernetes_deployment" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.kubernetes_dashboard,
    kubernetes_role_binding.kubernetes_dashboard,
    kubernetes_cluster_role_binding.kubernetes_dashboard,
    kubernetes_secret.kubernetes_dashboard_certs,
    kubernetes_secret.kubernetes_dashboard_csrf,
    kubernetes_secret.kubernetes_dashboard_key_holder,
    kubernetes_config_map.kubernetes_dashboard_settings
  ]
  metadata {
    name      = "kubernetes-dashboard"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "kubernetes-dashboard"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        k8s-app = "kubernetes-dashboard"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app = "kubernetes-dashboard"
        }
      }
      spec {
        volume {
          name = "kubernetes-dashboard-certs"
          secret {
            secret_name = "kubernetes-dashboard-certs"
          }
        }
        volume {
          name      = "tmp-volume"
          empty_dir {            
          }
        }
        container {
          name  = "kubernetes-dashboard"
          image = "kubernetesui/dashboard:v2.2.0"
          args  = ["--auto-generate-certificates", "--namespace=kubernetes-dashboard"]
          port {
            container_port = 8443
            protocol       = "TCP"
          }
          volume_mount {
            name       = "kubernetes-dashboard-certs"
            mount_path = "/certs"
          }
          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }
          liveness_probe {
            http_get {
              path   = "/"
              port   = "8443"
              scheme = "HTTPS"
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
          image_pull_policy = "Always"
          security_context {
            run_as_user               = 1001
            run_as_group              = 2001
            read_only_root_filesystem = true
          }
        }
        node_selector = {
          "kubernetes.io/os" = "linux"
          "node-role.kubernetes.io/control-plane" = ""
        }
        service_account_name = "kubernetes-dashboard"
        toleration {
          key    = "node-role.kubernetes.io/control-plane"
          effect = "NoSchedule"
        }
      }
    }
    revision_history_limit = 10
  }
}
resource "kubernetes_service" "dashboard_metrics_scraper" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard
  ]
  metadata {
    name      = "dashboard-metrics-scraper"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "dashboard-metrics-scraper"
    }
  }
  spec {
    port {
      port        = 8000
      target_port = "8000"
    }
    selector = {
      k8s-app = "dashboard-metrics-scraper"
    }
  }
}
resource "kubernetes_deployment" "dashboard_metrics_scraper" {
  depends_on = [
    kubernetes_namespace.kubernetes_dashboard,
    kubernetes_service_account.kubernetes_dashboard,
    kubernetes_service.dashboard_metrics_scraper,
    kubernetes_role_binding.kubernetes_dashboard,
    kubernetes_cluster_role_binding.kubernetes_dashboard,
    kubernetes_secret.kubernetes_dashboard_certs,
    kubernetes_secret.kubernetes_dashboard_csrf,
    kubernetes_secret.kubernetes_dashboard_key_holder,
    kubernetes_config_map.kubernetes_dashboard_settings
  ]
  metadata {
    name      = "dashboard-metrics-scraper"
    namespace = "kubernetes-dashboard"
    labels = {
      k8s-app = "dashboard-metrics-scraper"
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        k8s-app = "dashboard-metrics-scraper"
      }
    }
    template {
      metadata {
        labels = {
          k8s-app = "dashboard-metrics-scraper"
        }
        annotations = {
          "seccomp.security.alpha.kubernetes.io/pod" = "runtime/default"
        }
      }
      spec {
        volume {
          name      = "tmp-volume"
          empty_dir {            
          }
        }
        container {
          name  = "dashboard-metrics-scraper"
          image = "kubernetesui/metrics-scraper:v1.0.6"
          port {
            container_port = 8000
            protocol       = "TCP"
          }
          volume_mount {
            name       = "tmp-volume"
            mount_path = "/tmp"
          }
          liveness_probe {
            http_get {
              path   = "/"
              port   = "8000"
              scheme = "HTTP"
            }
            initial_delay_seconds = 30
            timeout_seconds       = 30
          }
          security_context {
            run_as_user               = 1001
            run_as_group              = 2001
            read_only_root_filesystem = true
          }
        }
        node_selector = {
          "kubernetes.io/os" = "linux"
          "node-role.kubernetes.io/control-plane" = ""
        }
        service_account_name = "kubernetes-dashboard"
        toleration {
          key    = "node-role.kubernetes.io/control-plane"
          effect = "NoSchedule"
        }
      }
    }
    revision_history_limit = 10
  }
}