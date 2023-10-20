#variables.tf
variable "xen_infra_settings" {
  type = object({
    xen_servers_settings = object({
      xen_network_name = string,
      xen_vm_template_name = string,
      xen_pool_name = string
    })
    master_vm_request    = object({
      vm_settings = object({
        name_label_prefix = string,
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
        nodes_mask = number,
        nodes_gateway = string,
        nodes_dns_address = string
      })
    })  
    worker_vm_request    = object({
      vm_settings = object({
        name_label_prefix = string,
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
        nodes_mask = number,
        nodes_gateway = string,
        nodes_dns_address = string
      })
    })
    node_storage_request = object({
      storage = object({
        system   = object({
          volume  = number,
          sr_ids  = list(string)
        })
        diskless   = object({
          count = number
        })
        ssd   = object({
          volume  = number,
          sr_ids  = list(string),
          count = number
        })
        nvme   = object({
          volume  = number,
          sr_ids  = list(string),
          count = number
        })
        hdd   = object({
          volume  = number,
          sr_ids  = list(string),
          count = number
        })
      })
    })
    dns_request = object({
      dns_key_name = string,
      dns_key_secret = string,
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
  validation {
    condition = var.xen_infra_settings.master_vm_request.vm_settings.count == 1 || var.xen_infra_settings.master_vm_request.vm_settings.count >= 3 
    error_message = "Master VM count must be 1 or 3 and more for HA"
  }
  validation {
    condition = var.xen_infra_settings.master_vm_request.vm_settings.cpu_count >= 2
    error_message = "Master VM CPU count must be great or equal 2"
  }
  validation {
    condition = var.xen_infra_settings.worker_vm_request.vm_settings.cpu_count >= 2
    error_message = "Worker VM CPU count must be great or equal 2"
  }
  validation {
    condition = can(cidrnetmask("${var.xen_infra_settings.master_vm_request.network_settings.node_address_mask}/${var.xen_infra_settings.master_vm_request.network_settings.nodes_mask}"))
    error_message = "CIDRnetmask Master VM validate error"
  }
  validation {
    condition = can(cidrnetmask("${var.xen_infra_settings.worker_vm_request.network_settings.node_address_mask}/${var.xen_infra_settings.worker_vm_request.network_settings.nodes_mask}"))
    error_message = "CIDRnetmask Worker VM validate error"
  }
  validation {
    condition = cidrhost("${var.xen_infra_settings.master_vm_request.network_settings.node_address_mask}/${var.xen_infra_settings.master_vm_request.network_settings.nodes_mask}", var.xen_infra_settings.master_vm_request.vm_settings.count + var.xen_infra_settings.master_vm_request.network_settings.node_address_start_ip) >= cidrhost("${var.xen_infra_settings.worker_vm_request.network_settings.node_address_mask}/${var.xen_infra_settings.worker_vm_request.network_settings.nodes_mask}", var.xen_infra_settings.worker_vm_request.network_settings.node_address_start_ip)
    error_message = "Master VM IP address mask conflict with Worker VM IP address mask"
  }  
  validation {
    condition = var.xen_infra_settings.master_vm_request.vm_settings.memory_size_gb >= 2 * 1024 * 1024 * 1024
    error_message = "Master VM MEM size must be great or equal 2GB"
  }
  validation {
    condition = var.xen_infra_settings.worker_vm_request.vm_settings.memory_size_gb >= 2 * 1024 * 1024 * 1024
    error_message = "Worker VM MEM size must be great or equal 2GB"
  }
  validation {
    condition = var.xen_infra_settings.node_storage_request.storage.ssd.volume != var.xen_infra_settings.node_storage_request.storage.nvme.volume && var.xen_infra_settings.node_storage_request.storage.ssd.volume != var.xen_infra_settings.node_storage_request.storage.hdd.volume
    error_message = "Volume size ssd must not equal nvme or hdd"
  }
  validation {
    condition = var.xen_infra_settings.node_storage_request.storage.nvme.volume != var.xen_infra_settings.node_storage_request.storage.ssd.volume && var.xen_infra_settings.node_storage_request.storage.nvme.volume != var.xen_infra_settings.node_storage_request.storage.hdd.volume
    error_message = "Volume size nvme must not equal ssd or hdd"
  }
  validation {
    condition = var.xen_infra_settings.node_storage_request.storage.hdd.volume != var.xen_infra_settings.node_storage_request.storage.ssd.volume && var.xen_infra_settings.node_storage_request.storage.hdd.volume != var.xen_infra_settings.node_storage_request.storage.nvme.volume
    error_message = "Volume size hdd must not equal ssd or nvme"
  }      
}