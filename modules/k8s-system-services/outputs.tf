#outputs.tf
output "k8s_kube-token-k8sadmin" {
  value = nonsensitive(kubernetes_token_request_v1.k8s_kube-token-k8sadmin_resource.token)
}
output "storage_available" {
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
        "volume"  = var.nodes[i].storage.ssd.volume
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