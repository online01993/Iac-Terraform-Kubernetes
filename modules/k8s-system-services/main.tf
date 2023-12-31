#main.tf
#Make Global labels
resource "kubernetes_labels" "kubernetes_labels_masters_topology_region" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.masters : i.id => i }
  field_manager = "TerraformLabels_masters_topology_region"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "topology.kubernetes.io/region" = "Main-Region"
  }
}
resource "kubernetes_labels" "kubernetes_labels_workers_topology_region" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.nodes : i.id => i }
  field_manager = "TerraformLabels_workers_topology_region"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "topology.kubernetes.io/region" = "Main-Region"
  }
}
resource "kubernetes_labels" "kubernetes_labels_masters_topology_zone" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.masters : i.id => i }
  field_manager = "TerraformLabels_masters_topology_zone"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "topology.kubernetes.io/zone" = "Main-Zone"
  }
}
resource "kubernetes_labels" "kubernetes_labels_workers_topology_zone" {
  depends_on = [
    kubernetes_namespace.kube_flannel,
    kubernetes_service_account.flannel,
    kubernetes_cluster_role.flannel,
    kubernetes_cluster_role_binding.flannel,
    kubernetes_config_map.kube_flannel_cfg,
    kubernetes_daemonset.kube_flannel_ds
  ]
  for_each = { for i in var.nodes : i.id => i }
  field_manager = "TerraformLabels_workers_topology_zone"
  api_version = "v1"
  kind        = "Node"
  metadata {
    name = each.value.netbios
  }
  labels = {
    "topology.kubernetes.io/zone" = "Main-Zone"
  }
}

resource "kubernetes_persistent_volume_claim" "pvc_ssd_replicated_1c_data" {
  depends_on = [
    kubernetes_storage_class.storage_class_ssd_storage_replicated
  ]
  metadata {
    name = "pvc-ssd-replicated-1c-data"
    namespace = "default"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "1Gi"
      }
    }
    storage_class_name = "storage-class-${var.ssd_k8s_stor_pool_type}-${var.ssd_k8s_stor_pool_name}-ssd-storage-replicated"
  }
  wait_until_bound = false
}