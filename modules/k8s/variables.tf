variable "vm_rsa_ssh_key_private" {
  type = string
}
variable "vm_rsa_ssh_key_public" {
  type = string
}
variable "masters" {
  type = list(object({
    id   = integer
    fqdn = string
	address = string
  }))
}
variable "nodes" {
  type = list(object({
    id   = integer
    fqdn = string
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