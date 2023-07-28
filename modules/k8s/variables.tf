variable "vm_rsa_ssh_key_private" {
  type = string
}
variable "vm_rsa_ssh_key_public" {
  type = string
}
variable "masters" {
  type = list(object({
    id   = number
    fqdn = string
	address = string
  }))
}
variable "nodes" {
  type = list(object({
    id   = number
    fqdn = string
	address = string
  }))
}
variable "master_count" {
  #default = 3
  type = number
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
variable "pods_address_mask" {
  #default = 10.244.0.
  type = string
}
variable "pods_mask_cidr" {
  #default = 16
  type = string
}