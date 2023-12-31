variable "vm_rsa_ssh_key_private" {
  type = string
}
variable "vm_rsa_ssh_key_public" {
  type = string
}
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
variable "version_containerd" {
  type = string
}
variable "version_runc" {
  type = string
}
variable "version_cni-plugin" {
  type = string
}
variable "master_node_address_mask" {
  #default = 10.244.0.
  type = string
}
variable "master_node_address_start_ip" {
  #default = 11
  type = number
}
variable "pods_mask_cidr" {
  #default = ""
  type = string
}
variable "k8s_api_endpoint_ip" {
  #default = 16
  type = string
}
variable "k8s_api_endpoint_port" {
  #default = 8888
  type = string
}