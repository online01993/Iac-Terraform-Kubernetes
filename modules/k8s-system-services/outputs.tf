#outputs.tf
output "k8s_kube-token-k8sadmin" {
  value = nonsensitive(kubernetes_token_request_v1.k8s_kube-token-k8sadmin_resource.token)
}
output "storage_available" {
  value = [
    for i in range(length(var.node)) : 
    {
      "id"      = i
      "netbios" = var.node[i].netbios
      "fqdn"    = var.node[i].fqdn
      "address" = var.node[i].address
      "storage_classes" = ({
      "ssd"   = var.node[i].storage.ssd.present ? ({
        "present" = var.node[i].storage.ssd.present,
        "hostPath" = var.node[i].storage.ssd.hostPath,
        "volume"  = var.node[i].storage.ssd.volume
      }) : null
      "nvme"   = var.node[i].storage.nvme.present ? ({
        "present" = var.node[i].storage.nvme.present,
        "hostPath" = var.node[i].storage.nvme.hostPath,
        "volume"  = var.node[i].storage.nvme.volume
      }) : null
      "hdd"   = var.node[i].storage.hdd.present ? ({
        "present" = var.node[i].storage.hdd.present,
        "hostPath" = var.node[i].storage.hdd.hostPath,
        "volume"  = var.node[i].storage.hdd.volume
      }) : null
    })
    } if var.node[i].storage.ssd.present || var.node[i].storage.nvme.present || var.node[i].storage.hdd.present
  ]
}