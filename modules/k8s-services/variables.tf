#variables.tf
variable "k8s_cni_hairpinMode" {
  default = true
  type = bool
}
variable "k8s_cni_isDefaultGateway" {
  default = true
  type = bool
}
variable "k8s_cni_Backend_Type" {
  default = "vxlan"
  type = string
}
variable "pods_mask_cidr" {
  #default = ""
  type = string
}
variable "k8s-url" {
  #default = ""
  type = string
}
variable "k8s-endpont" {
  #default = ""
  type = string
}
variable "k8s-admin_file" {
  #default = ""
  type = string
  sensitive   = true
}