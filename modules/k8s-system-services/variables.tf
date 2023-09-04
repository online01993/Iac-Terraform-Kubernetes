#variables.tf
variable "masters" {
  type = list(object({
    id      = number
    netbios = string
    fqdn    = string
    address = string
  }))
}
variable "nodes" {
  type = list(object({
    id      = number
    netbios = string
    fqdn    = string
    address = string
    storage = object({
      ssd   = object({
        present = bool,
        hostPath = string,
        volume  = number
      })
      nvme   = object({
        present = bool,
        hostPath = string,
        volume  = number
      })
      hdd   = object({
        present = bool,
        hostPath = string,
        volume  = number
      })
    })
  }))
}
variable "ssd_k8s_stor_pool_type" {
  default = "thin"
  type = string
  validation {
    condition     = can(regex("^(thin|thick)$", var.ssd_k8s_stor_pool_type))
    error_message = "Invalid ssd_k8s_stor_pool_type selected, only allowed are: 'thin', 'thick'"
  }
}
variable "ssd_k8s_stor_pool_name" {
  default = var.ssd_k8s_stor_pool_type"-ssd-pool"
  type = string
}
variable "nvme_k8s_stor_pool_type" {
  default = "thin"
  type = string
  validation {
    condition     = can(regex("^(thin|thick)$", var.nvme_k8s_stor_pool_type))
    error_message = "Invalid nvme_k8s_stor_pool_type selected, only allowed are: 'thin', 'thick'"
  }
}
variable "nvme_k8s_stor_pool_name" {
  default = "${var.nvme_k8s_stor_pool_type}-nvme-pool"
  type = string
}
variable "hdd_k8s_stor_pool_type" {
  default = "thin"
  type = string
  validation {
    condition     = can(regex("^(thin|thick)$", var.hdd_k8s_stor_pool_type))
    error_message = "Invalid hdd_k8s_stor_pool_type selected, only allowed are: 'thin', 'thick'"
  }
}
variable "hdd_k8s_stor_pool_name" {
  default = "${var.hdd_k8s_stor_pool_type}-hdd-pool"
  type = string
}
variable "pods_mask_cidr" {
  #default = ""
  type = string
}
variable "k8s_cni_hairpinMode" {
  default = true
  type    = bool
}
variable "k8s_cni_isDefaultGateway" {
  default = true
  type    = bool
}
variable "k8s_cni_Backend_Type" {
  default = "vxlan"
  type    = string
}
variable "kube-dashboard_nodePort" {
  default = 30100
  type    = number
}