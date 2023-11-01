variable "vm_rsa_ssh_key_private" {
  type = string
}
variable "vm_rsa_ssh_key_public" {
  type = string
}
variable "masters" {
  type = list(object({
    id      = number
    address = string
  }))
}
variable "nodes" {
  type = list(object({
    id      = number
    address = string
  }))
}
variable "kubernetes_infra_setup_settings" {
  type = object({
    kubernetes_settings = object({
      master_node_address_mask = string, #default = 10.244.0.
      master_node_address_start_ip = number, #default = 11
      version_containerd = string, #Runtime containerd version, https://github.com/containerd/containerd/releases
      version_runc = string, #Runtime runc library version, https://github.com/opencontainers/runc/releases/download
      version_cni-plugin = string, #CNI network plugin, https://github.com/containernetworking/plugins/releases/download
      k8s_api_endpoint_ip = string, #IP address endpoint of Kubernetes cluster
      k8s_api_endpoint_port = number, #IP PORT endpoint of Kubernetes cluster via VRRP_HAProxy
      k8s_cni_hairpinMode = bool, #Make NAT for CNI pod network
      k8s_cni_isDefaultGateway = bool, #Make default gateway for CNI pod network
      k8s_cni_Backend_Type = string #Backend type for CNI pod network
    })
    pods_request = object({
      network_settings = object({
        pods_address_mask = string, #PODS adress mask in CIDR format, default 10.244.0.0
        pods_mask_bits = number #PODS mask bits, default 16
      })
    })
  })
  validation {
    condition = can(regex("^(vxlan|vxlan)$", var.kubernetes_infra_setup_settings.kubernetes_settings.k8s_cni_Backend_Type))
    error_message = "Invalid k8s_cni_Backend_Type selected, only allowed types are: 'vxlan'"
  }
  validation {
    condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$",var.kubernetes_infra_setup_settings.kubernetes_settings.k8s_api_endpoint_ip))
    error_message = "Invalid k8s_api_endpoint_ip address provided"
  } 
  validation {
    condition = can(regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$","${var.kubernetes_infra_setup_settings.kubernetes_settings.master_node_address_mask}${var.kubernetes_infra_setup_settings.kubernetes_settings.master_node_address_start_ip}"))
    error_message = "Invalid master_node_address_mask AND/OR master_node_address_start_ip address provided"
  }
  validation {
    condition = var.kubernetes_infra_setup_settings.kubernetes_settings.k8s_api_endpoint_port > 1024 && var.kubernetes_infra_setup_settings.kubernetes_settings.k8s_api_endpoint_port <= 65535
    error_message = "Invalid k8s_api_endpoint_port provided, set correct port between 1024 and 65535"
  }
}