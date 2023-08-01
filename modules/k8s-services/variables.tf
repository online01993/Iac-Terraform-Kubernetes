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