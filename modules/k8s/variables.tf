variable "vm_rsa_ssh_key" {
  type = string
}
variable "nodes" {
  type = map(string)
  #default = {}
}
variable "masters" {
  type = map(string)
  #default = {}
}
variable "nodes_ips" {
  type = map(string)
  #default = {}
}
variable "masters_ips" {
  type = map(string)
  #default = {}
}