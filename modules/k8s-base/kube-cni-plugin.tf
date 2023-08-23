#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
##kubectl provider solution
/*resource "kubectl_manifest" "k8s_cni_plugin" {
  for_each = {
    for i in toset([
      for index, i in (split("---", templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr     = "${var.pods_mask_cidr}"
        cni_hairpinMode      = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type     = "${var.k8s_cni_Backend_Type}"
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
resource "kubernetes_namespace" "kube_flannel" {
  depends_on = [
    terraform_data.k8s-kubeadm-join_masters_04_resource,
    terraform_data.k8s-kubeadm-join_nodes_04_resource
  ]
  metadata {
    name = "kube-flannel"
    labels = {
      k8s-app = "flannel"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}
resource "kubernetes_service_account" "flannel" {
  depends_on = [
    kubernetes_namespace.kube_flannel
  ]
  metadata {
    name      = "flannel"
    namespace = "kube-flannel"
    labels = {
      k8s-app = "flannel"
    }
  }
}
resource "kubernetes_cluster_role" "flannel" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel
  ]
  metadata {
    name = "flannel"
    labels = {
      k8s-app = "flannel"
    }
  }
  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["pods"]
  }
  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }
  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["nodes/status"]
  }
  rule {
    verbs      = ["list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["clustercidrs"]
  }
}
resource "kubernetes_cluster_role_binding" "flannel" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel
  ]
  metadata {
    name = "flannel"
    labels = {
      k8s-app = "flannel"
    }
  }
  subject {
    kind      = "ServiceAccount"
    name      = "flannel"
    namespace = "kube-flannel"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "flannel"
  }
}
resource "kubernetes_config_map" "kube_flannel_cfg" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel
  ]
  metadata {
    name      = "kube-flannel-cfg"
    namespace = "kube-flannel"
    labels = {
      app = "flannel"
      k8s-app = "flannel"
      tier = "node"
    }
  }
  data = {
    "cni-conf.json" = "{\n  \"name\": \"cbr0\",\n  \"cniVersion\": \"0.3.1\",\n  \"plugins\": [\n    {\n      \"type\": \"flannel\",\n      \"delegate\": {\n        \"hairpinMode\": ${var.k8s_cni_hairpinMode},\n        \"isDefaultGateway\": ${var.k8s_cni_isDefaultGateway}\n      }\n    },\n    {\n      \"type\": \"portmap\",\n      \"capabilities\": {\n        \"portMappings\": true\n      }\n    }\n  ]\n}\n"
    "net-conf.json" = "{\n  \"Network\": \"${var.pods_mask_cidr}\",\n  \"Backend\": {\n    \"Type\": \"${var.k8s_cni_Backend_Type}\"\n  }\n}\n"
  }
}
resource "kubernetes_daemonset" "kube_flannel_ds" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg
  ]
  metadata {
    name      = "kube-flannel-ds"
    namespace = "kube-flannel"
    labels = {
      app = "flannel"
      k8s-app = "flannel"
      tier = "node"
    }
  }
  spec {
    selector {
      match_labels = {
        app = "flannel"
      }
    }
    template {
      metadata {
        labels = {
          app = "flannel"
          tier = "node"
        }
      }
      spec {
        volume {
          name = "run"
          host_path {
            path = "/run/flannel"
          }
        }
        volume {
          name = "cni-plugin"
          host_path {
            path = "/opt/cni/bin"
          }
        }
        volume {
          name = "cni"
          host_path {
            path = "/etc/cni/net.d"
          }
        }
        volume {
          name = "flannel-cfg"
          config_map {
            name = "kube-flannel-cfg"
          }
        }
        volume {
          name = "xtables-lock"
          host_path {
            path = "/run/xtables.lock"
            type = "FileOrCreate"
          }
        }
        init_container {
          name    = "install-cni-plugin"
          image   = "docker.io/flannel/flannel-cni-plugin:v1.2.0"
          command = ["cp"]
          args    = ["-f", "/flannel", "/opt/cni/bin/flannel"]
          volume_mount {
            name       = "cni-plugin"
            mount_path = "/opt/cni/bin"
          }
        }
        init_container {
          name    = "install-cni"
          image   = "docker.io/flannel/flannel:v0.22.1"
          command = ["cp"]
          args    = ["-f", "/etc/kube-flannel/cni-conf.json", "/etc/cni/net.d/10-flannel.conflist"]
          volume_mount {
            name       = "cni"
            mount_path = "/etc/cni/net.d"
          }
          volume_mount {
            name       = "flannel-cfg"
            mount_path = "/etc/kube-flannel/"
          }
        }
        container {
          name    = "kube-flannel"
          image   = "docker.io/flannel/flannel:v0.22.1"
          command = ["/opt/bin/flanneld"]
          args    = ["--ip-masq", "--kube-subnet-mgr"]
          env {
            name = "POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name  = "EVENT_QUEUE_DEPTH"
            value = "5000"
          }
          resources {
            requests = {
              cpu = "100m"
              memory = "50Mi"
            }
          }
          volume_mount {
            name       = "run"
            mount_path = "/run/flannel"
          }
          volume_mount {
            name       = "flannel-cfg"
            mount_path = "/etc/kube-flannel/"
          }
          volume_mount {
            name       = "xtables-lock"
            mount_path = "/run/xtables.lock"
          }
          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW"]
            }
          }
        }
        service_account_name = "flannel"
        host_network         = true
        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "kubernetes.io/os"
                  operator = "In"
                  values   = ["linux"]
                }
              }
            }
          }
        }
        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }
        priority_class_name = "system-node-critical"
      }
    }
  }
}