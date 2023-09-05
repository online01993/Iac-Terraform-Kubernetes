#outputs.tf
output "k8s_kube-token-k8sadmin" {
  value = nonsensitive(kubernetes_token_request_v1.k8s_kube-token-k8sadmin_resource.token)
}
output "storage_available" {
  value = [
    for i in var.nodes if (i.storage.ssd.present || i.storage.nvme.present || i.storage.hdd.present) :
    {
      "id"      = i
      "netbios" = i.netbios
      "fqdn"    = i.fqdn
      "address" = i.address
      "storage_classes" = ({
      "ssd"   = i.storage.ssd.present ? ({
        "present" = i.ssd.present,
        "hostPath" = i.ssd.hostPath,
        "volume"  = i.ssd.volume
      }) : null
      "nvme"   = i.storage.nvme.present ? ({
        "present" = i.nvme.present,
        "hostPath" = i.nvme.hostPath,
        "volume"  = i.nvme.volume
      }) : null
      "hdd"   = i.storage.hdd.present ? ({
        "present" = i.hdd.present,
        "hostPath" = i.hdd.hostPath,
        "volume"  = i.hdd.volume
      }) : null
    })
    }
  ]
}