#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
/*locals {
  crds_rendered_content = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr             = "${var.pods_mask_cidr}"
        cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"  
    })
  crds_split_doc  = split("---", file("${path.module}/scripts/kube-flannel.yml.tpl"))
  #crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(keys(local.crds_valid_yaml)) : yamldecode(doc).metadata.name => doc }
}
resource "kubectl_manifest" "k8s_cni_plugin" {
  for_each  = local.crds_dict
  yaml_body = each.value
} */
/*data "kubectl_path_documents" "k8s_cni_plugin_yaml_file" {
 pattern                       = "${path.module}/scripts/kube-flannel.yml.tpl"
 vars                          = {
  pod-network-cidr             = "${var.pods_mask_cidr}"
  cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
  cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
  cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"
 } 
}
data "kubectl_file_documents" "k8s_cni_plugin_yaml_file" {
    content = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr             = "${var.pods_mask_cidr}"
        cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"  
    }
)
}
resource "kubectl_manifest" "k8s_cni_plugin" {
# depends_on                    = [
    #data.kubectl_path_documents.k8s_cni_plugin_yaml_file
    #data.kubectl_file_documents.k8s_cni_plugin_yaml_file
 #]
 #for_each                      = data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents
 #yaml_body                     = each.value
 count      = length(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents)
 yaml_body  = element(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents, count.index)
}*/
resource "kubernetes_manifest" "namespace_kube_flannel" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "Namespace"
    "metadata" = {
      "labels" = {
        "k8s-app" = "flannel"
        "pod-security.kubernetes.io/enforce" = "privileged"
      }
      "name" = "kube-flannel"
    }
  }
}

resource "kubernetes_manifest" "clusterrole_flannel" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRole"
    "metadata" = {
      "labels" = {
        "k8s-app" = "flannel"
      }
      "name" = "flannel"
    }
    "rules" = [
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "pods",
        ]
        "verbs" = [
          "get",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes",
        ]
        "verbs" = [
          "get",
          "list",
          "watch",
        ]
      },
      {
        "apiGroups" = [
          "",
        ]
        "resources" = [
          "nodes/status",
        ]
        "verbs" = [
          "patch",
        ]
      },
      {
        "apiGroups" = [
          "networking.k8s.io",
        ]
        "resources" = [
          "clustercidrs",
        ]
        "verbs" = [
          "list",
          "watch",
        ]
      },
    ]
  }
}

resource "kubernetes_manifest" "clusterrolebinding_flannel" {
  manifest = {
    "apiVersion" = "rbac.authorization.k8s.io/v1"
    "kind" = "ClusterRoleBinding"
    "metadata" = {
      "labels" = {
        "k8s-app" = "flannel"
      }
      "name" = "flannel"
    }
    "roleRef" = {
      "apiGroup" = "rbac.authorization.k8s.io"
      "kind" = "ClusterRole"
      "name" = "flannel"
    }
    "subjects" = [
      {
        "kind" = "ServiceAccount"
        "name" = "flannel"
        "namespace" = "kube-flannel"
      },
    ]
  }
}

resource "kubernetes_manifest" "serviceaccount_kube_flannel_flannel" {
  manifest = {
    "apiVersion" = "v1"
    "kind" = "ServiceAccount"
    "metadata" = {
      "labels" = {
        "k8s-app" = "flannel"
      }
      "name" = "flannel"
      "namespace" = "kube-flannel"
    }
  }
}

resource "kubernetes_manifest" "configmap_kube_flannel_kube_flannel_cfg" {
  manifest = {
    "apiVersion" = "v1"
    "data" = {
      "cni-conf.json" = <<-EOT
      {
        "name": "cbr0",
        "cniVersion": "0.3.1",
        "plugins": [
          {
            "type": "flannel",
            "delegate": {
              "hairpinMode": "${var.cni_hairpinMode}",
              "isDefaultGateway": "${var.cni_isDefaultGateway}"
            }
          },
          {
            "type": "portmap",
            "capabilities": {
              "portMappings": true
            }
          }
        ]
      }
      
      EOT
      "net-conf.json" = <<-EOT
      {
        "Network": "${var.pod-network-cidr}",
        "Backend": {
          "Type": "${var.cni_Backend_Type}"
        }
      }
      EOT
    }
    "kind" = "ConfigMap"
    "metadata" = {
      "labels" = {
        "app" = "flannel"
        "k8s-app" = "flannel"
        "tier" = "node"
      }
      "name" = "kube-flannel-cfg"
      "namespace" = "kube-flannel"
    }
  }
}

resource "kubernetes_manifest" "daemonset_kube_flannel_kube_flannel_ds" {
  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "DaemonSet"
    "metadata" = {
      "labels" = {
        "app" = "flannel"
        "k8s-app" = "flannel"
        "tier" = "node"
      }
      "name" = "kube-flannel-ds"
      "namespace" = "kube-flannel"
    }
    "spec" = {
      "selector" = {
        "matchLabels" = {
          "app" = "flannel"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app" = "flannel"
            "tier" = "node"
          }
        }
        "spec" = {
          "affinity" = {
            "nodeAffinity" = {
              "requiredDuringSchedulingIgnoredDuringExecution" = {
                "nodeSelectorTerms" = [
                  {
                    "matchExpressions" = [
                      {
                        "key" = "kubernetes.io/os"
                        "operator" = "In"
                        "values" = [
                          "linux",
                        ]
                      },
                    ]
                  },
                ]
              }
            }
          }
          "containers" = [
            {
              "args" = [
                "--ip-masq",
                "--kube-subnet-mgr",
              ]
              "command" = [
                "/opt/bin/flanneld",
              ]
              "env" = [
                {
                  "name" = "POD_NAME"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.name"
                    }
                  }
                },
                {
                  "name" = "POD_NAMESPACE"
                  "valueFrom" = {
                    "fieldRef" = {
                      "fieldPath" = "metadata.namespace"
                    }
                  }
                },
                {
                  "name" = "EVENT_QUEUE_DEPTH"
                  "value" = "5000"
                },
              ]
              "image" = "docker.io/flannel/flannel:v0.22.1"
              "name" = "kube-flannel"
              "resources" = {
                "requests" = {
                  "cpu" = "100m"
                  "memory" = "50Mi"
                }
              }
              "securityContext" = {
                "capabilities" = {
                  "add" = [
                    "NET_ADMIN",
                    "NET_RAW",
                  ]
                }
                "privileged" = false
              }
              "volumeMounts" = [
                {
                  "mountPath" = "/run/flannel"
                  "name" = "run"
                },
                {
                  "mountPath" = "/etc/kube-flannel/"
                  "name" = "flannel-cfg"
                },
                {
                  "mountPath" = "/run/xtables.lock"
                  "name" = "xtables-lock"
                },
              ]
            },
          ]
          "hostNetwork" = true
          "initContainers" = [
            {
              "args" = [
                "-f",
                "/flannel",
                "/opt/cni/bin/flannel",
              ]
              "command" = [
                "cp",
              ]
              "image" = "docker.io/flannel/flannel-cni-plugin:v1.2.0"
              "name" = "install-cni-plugin"
              "volumeMounts" = [
                {
                  "mountPath" = "/opt/cni/bin"
                  "name" = "cni-plugin"
                },
              ]
            },
            {
              "args" = [
                "-f",
                "/etc/kube-flannel/cni-conf.json",
                "/etc/cni/net.d/10-flannel.conflist",
              ]
              "command" = [
                "cp",
              ]
              "image" = "docker.io/flannel/flannel:v0.22.1"
              "name" = "install-cni"
              "volumeMounts" = [
                {
                  "mountPath" = "/etc/cni/net.d"
                  "name" = "cni"
                },
                {
                  "mountPath" = "/etc/kube-flannel/"
                  "name" = "flannel-cfg"
                },
              ]
            },
          ]
          "priorityClassName" = "system-node-critical"
          "serviceAccountName" = "flannel"
          "tolerations" = [
            {
              "effect" = "NoSchedule"
              "operator" = "Exists"
            },
          ]
          "volumes" = [
            {
              "hostPath" = {
                "path" = "/run/flannel"
              }
              "name" = "run"
            },
            {
              "hostPath" = {
                "path" = "/opt/cni/bin"
              }
              "name" = "cni-plugin"
            },
            {
              "hostPath" = {
                "path" = "/etc/cni/net.d"
              }
              "name" = "cni"
            },
            {
              "configMap" = {
                "name" = "kube-flannel-cfg"
              }
              "name" = "flannel-cfg"
            },
            {
              "hostPath" = {
                "path" = "/run/xtables.lock"
                "type" = "FileOrCreate"
              }
              "name" = "xtables-lock"
            },
          ]
        }
      }
    }
  }
}