#variables.tf
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
/*variable "pods_mask_cidr" {
  #default = ""
  type = string
}*/
variable "k8s-url" {
  #default = ""
  type = string
}
variable "kube-dashboard_nodePort" {
  default = 30100
  type    = number
}
variable "k8s-endpont" {
  #default = ""
  type = string
}
variable "k8s-admin_file" {
  #default = ""
  type      = string
  sensitive = true
}
variable "k8s-client-certificate-data" {
  #default = ""
  type      = string
  sensitive = true
}
variable "k8s-client-key-data" {
  #default = ""
  type      = string
  sensitive = true
}
variable "k8s-certificate-authority-data" {
  #default = ""
  type      = string
  sensitive = true
}