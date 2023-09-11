#variables.tf
variable "xen_infra_settings" object({
  xen_servers_settings = object({
    xen_network_name = string,
    xen_vm_template_name = string,
    xen_pool_name = string
  })
  master_vm_request    = object({
    vm_settings = object({
      count = number,
      cpu_count = number,
      memory_size_gb = number,
      labels = map(string),
      vm_tags = list(string)
    })
    network_settings = object({
      node_address_mask = string,
      node_address_start_ip = number,
      node_network_dhcp = bool,
      nodes_mask = string,
      nodes_gateway = string,
      nodes_dns_address = string
    })
  })  
  worker_vm_request    = object({
    vm_settings = object({
      count = number,
      cpu_count = number,
      memory_size_gb = number,
      labels = map(string),
      vm_tags = list(string)
    })
    network_settings = object({
      node_address_mask = string,
      node_address_start_ip = number,
      node_network_dhcp = bool,
      nodes_mask = string,
      nodes_gateway = string,
      nodes_dns_address = string
    })
  })
  node_storage_request = object({
    storage = object({
      system   = object({
        hostPath = string,
        volume  = number,
        sr_ids  = list(string)
      })
      diskless   = object({
        count = number
      })
      ssd   = object({
        hostPath = string,
        volume  = number,
        sr_ids  = list(string),
        count = number
      })
      nvme   = object({
        hostPath = string,
        volume  = number,
        sr_ids  = list(string),
        count = number
      })
      hdd   = object({
        hostPath = string,
        volume  = number,
        sr_ids  = list(string),
        count = number
      })
    })
  })
  dns_request = object({
    dns_key_name = string,
    dns_key_secret = sensitive(string),
    dns_server = string,
    dns_zone = string,
    dns_sub_zone = string,
    dns_ttl = number 
  })
  certificate_request = object({
    organization        = string,
    organizational_unit = string,
    locality            = string,
    country             = string,
    province            = string
  })
  ssh_auth_request = object({
    vm_rsa_ssh_key = string
  })
})