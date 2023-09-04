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

resource "kubernetes_persistent_volume_claim" "pvc_ssd_replicated" {
  depends_on = [
    kubernetes_storage_class.storage_class_ssd_storage_replicated
  ]
  /* lifecycle {
    replace_triggered_by = [
      kubectl_manifest.LinstorCluster_piraeus_datastore.uid,
      kubectl_manifest.LinstorSatelliteConfiguration_piraeus_datastore_ssd,
      kubectl_manifest.StorageClass_drbd_storage_piraeus_datastore_ssd
    ]
  } */
  metadata {
    name = "replicated-volume"
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
}