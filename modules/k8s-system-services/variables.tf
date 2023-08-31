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
  }))
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