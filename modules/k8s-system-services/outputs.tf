#outputs.tf
output "k8s_kube-token-k8sadmin" {
  value = nonsensitive(kubernetes_token_request_v1.k8s_kube-token-k8sadmin_resource.token)
}
output "nodes_with_storage_available" {
  value = [
    for i in range(length(var.nodes)) : 
    {
      "id"      = i
      "netbios" = var.nodes[i].netbios
      "fqdn"    = var.nodes[i].fqdn
      "address" = var.nodes[i].address
      "storage_classes" = ({
      "ssd"   = var.nodes[i].storage.ssd.present ? ({
        "present" = var.nodes[i].storage.ssd.present,
        "hostPath" = var.nodes[i].storage.ssd.hostPath,
        "volume"  = var.nodes[i].storage.ssd.volume,
        "storage_class_name" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].metadata[0].name
        "storage_class_reclaim_policy" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].reclaim_policy
        "storage_class_storage_provisioner" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].storage_provisioner
        "storage_class_volume_binding_mode" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].volume_binding_mode
      }) : null
      "nvme"   = var.nodes[i].storage.nvme.present ? ({
        "present" = var.nodes[i].storage.nvme.present,
        "hostPath" = var.nodes[i].storage.nvme.hostPath,
        "volume"  = var.nodes[i].storage.nvme.volume
      }) : null
      "hdd"   = var.nodes[i].storage.hdd.present ? ({
        "present" = var.nodes[i].storage.hdd.present,
        "hostPath" = var.nodes[i].storage.hdd.hostPath,
        "volume"  = var.nodes[i].storage.hdd.volume
      }) : null
    })
    } if var.nodes[i].storage.ssd.present || var.nodes[i].storage.nvme.present || var.nodes[i].storage.hdd.present
  ]
}
output "storage_available" {
  value = [
    {
      "storage_classes" = ({
      "ssd"   = kubernetes_storage_class.storage_class_ssd_storage_replicated.count > 0 ? ({
        "storage_class_name" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].metadata[0].name
        "storage_class_reclaim_policy" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].reclaim_policy
        "storage_class_storage_provisioner" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].storage_provisioner
        "storage_class_volume_binding_mode" = kubernetes_storage_class.storage_class_ssd_storage_replicated[0].volume_binding_mode
      }) : null
      "nvme"   = kubernetes_storage_class.storage_class_nvme_storage_replicated.count > 0 ? ({
        "storage_class_name" = kubernetes_storage_class.storage_class_nvme_storage_replicated[0].metadata[0].name
        "storage_class_reclaim_policy" = kubernetes_storage_class.storage_class_nvme_storage_replicated[0].reclaim_policy
        "storage_class_storage_provisioner" = kubernetes_storage_class.storage_class_nvme_storage_replicated[0].storage_provisioner
        "storage_class_volume_binding_mode" = kubernetes_storage_class.storage_class_nvme_storage_replicated[0].volume_binding_mode
      }) : null
      "hdd"   = kubernetes_storage_class.storage_class_hdd_storage_replicated.count > 0 ? ({
        "storage_class_name" = kubernetes_storage_class.storage_class_hdd_storage_replicated[0].metadata[0].name
        "storage_class_reclaim_policy" = kubernetes_storage_class.storage_class_hdd_storage_replicated[0].reclaim_policy
        "storage_class_storage_provisioner" = kubernetes_storage_class.storage_class_hdd_storage_replicated[0].storage_provisioner
        "storage_class_volume_binding_mode" = kubernetes_storage_class.storage_class_hdd_storage_replicated[0].volume_binding_mode
      }) : null
    })
    } 
  ]
}