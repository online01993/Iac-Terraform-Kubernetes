variable "master_node_network_dhcp" {
  default = true
  type    = bool
}
variable "worker_node_network_dhcp" {
  default = true
  type    = bool
}
variable "master_node_address_mask" {
  #default = 10.244.0.
  type = string
}
variable "master_node_address_start_ip" {
  #default = 11
  type = number
}
variable "worker_node_address_mask" {
  #default = 10.244.0.
  type = string
}
variable "worker_node_address_start_ip" {
  #default = 20
  type = number
}
variable "nodes_mask" {
  #default = 255.255.0.0
  type = string
}
variable "nodes_gateway" {
  #default = 10.244.0.
  type = string
}
variable "nodes_dns_address" {
  #default = 10.244.0.1
  type = string
}
variable "node_count" {
  #default = 6
  type = number
}
variable "vm_disk_size_gb" {
  #default = 16
  type = number
}
variable "vm_storage_disk_size_gb" {
  #default = 150
  type = number
}
variable "vm_memory_size_gb" {
  #default = 1
  type = number
}
variable "vm_cpu_count" {
  #default = 1
  type = number
}
variable "master_count" {
  #default = 3
  type = number
}
variable "master_disk_size_gb" {
  #default = 16
  type = number
}
variable "master_memory_size_gb" {
  #default = 1
  type = number
}
variable "master_cpu_count" {
  #default = 1
  type = number
}
variable "dns_key_name" {
  type = string
}
variable "dns_key_secret" {
  sensitive = true
  type      = string
}
variable "dns_server" {
  type = string
}
variable "dns_zone" {
  type = string
}
variable "dns_sub_zone" {
  type = string
}
variable "dns_ttl" {
  type    = number
  default = 600
}
variable "certificate_params" {
  type = object({
    organization        = string
    organizational_unit = string
    locality            = string
    country             = string
    province            = string
  })
  #default = {
  #  organization        = "Test"
  #  organizational_unit = "Test"
  #  locality            = "Montreal"
  #  country             = "CA"
  #  province            = "QC"
  #}
}
variable "node_labels" {
  type = map(string)
  #default = {}
}
variable "master_labels" {
  type = map(string)
  #default = {}
}
variable "master_vm_tags" {
  type = list(string)
  #default = []
}
variable "node_vm_tags" {
  type = list(string)
  #default = []
}
variable "xen_sr_id" {
  type = list(string)
}
variable "xen_large_sr_id" {
  type = list(string)
}
variable "xen_network_name" {
  type = string
}
variable "xen_vm_template_name" {
  type = string
}
variable "xen_pool_name" {
  type = string
}
variable "vm_rsa_ssh_key" {
  type = string
}
variable "node_storage_request" {
  type = object({
    storage = object({
      system   = object({
        hostPath = string,
        sr_ids  = string
      })
      diskless   = object({
        present = bool,
        count = number
      })
      ssd   = object({
        present = bool,
        hostPath = string,
        volume  = number,
        sr_ids  = string,
        count = number
      })
      nvme   = object({
        present = bool,
        hostPath = string,
        volume  = number,
        sr_ids  = string,
        count = number
      })
      hdd   = object({
        present = bool,
        hostPath = string,
        volume  = number,
        sr_ids  = string,
        count = number
      })
    })
  })
}