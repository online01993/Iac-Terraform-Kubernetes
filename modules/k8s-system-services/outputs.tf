#outputs.tf
output "k8s_kube-token-k8sadmin" {
  value = nonsensitive(kubernetes_token_request_v1.k8s_kube-token-k8sadmin_resource.token)
}
output "storage_available" {
  value = [
    for i in var.nodes : 
    {
      "id"      = i
      "netbios" = i.netbios
      "fqdn"    = i.fqdn
      "address" = i.address
      "storage_classes" = ({
      "ssd"   = i.storage.ssd.present ? ({
        "present" = i.storage.ssd.present,
        "hostPath" = i.storage.ssd.hostPath,
        "volume"  = i.storage.ssd.volume
      }) : null
      "nvme"   = i.storage.nvme.present ? ({
        "present" = i.storage.nvme.present,
        "hostPath" = i.storage.nvme.hostPath,
        "volume"  = i.storage.nvme.volume
      }) : null
      "hdd"   = i.storage.hdd.present ? ({
        "present" = i.storage.hdd.present,
        "hostPath" = i.storage.hdd.hostPath,
        "volume"  = i.storage.hdd.volume
      }) : null
    })
    } if i.storage.ssd.present || i.storage.nvme.present || i.storage.hdd.present
  ]
}