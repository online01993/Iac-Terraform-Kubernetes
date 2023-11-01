#
# MAIN FILE TO VARIABLES SET
#

#
# XenOrchestra teraform provider settings
#
#Address to connect XO orhestra for xen mgmt
global_xen_xoa_url = "ws://10.1.84.212"
#XO orhestra login username
global_xen_xoa_username = "admin"
#XO orhestra login password
global_xen_xoa_password = "nt[yjkjubz"
#XO use secure ssl false|true
global_xen_xoa_insecure = true


#
# Xen ifra deploy request
#
global_xen_infra_settings = {
  "xen_servers_settings" = {
    "xen_network_name" = "Network 0 - LAN",
    "xen_vm_template_name" = "templateDebianCloudReadyWithXenUtils",
    "xen_pool_name" = "xcp-ng-homepool"
  }
  "master_vm_request"    = {
    "vm_settings" = {
      "name_label_prefix" = "deb11-k8s-master",
      "count" = 3,
      "cpu_count" = 2,
      "memory_size_gb" = 2 * 1024 * 1024 * 1024, # GB to B,
      "labels" = {
        "ntmax.ca/cloud-platform" = "xcp-ng"
        "ntmax.ca/cloud-os"       = "debian-11-focal"
        "ntmax.ca/region"         = "mtl-south-1"
      }
      "vm_tags" = [
          "ntmax.ca/cloud-os:debian-11-focal",
          "ntmax.ca/middleware:kubernetes",
          "ntmax.ca/provisionning:ansible",
          "ntmax.ca/provisionning:terraform",
          "kubernetes.io/role:master"
      ]
    }
    "network_settings" = {
      "node_address_mask" = "10.200.0.0",
      "node_address_start_ip" = 11,
      "node_network_dhcp" = false,
      "nodes_mask" = 240,
      "nodes_gateway" = "10.200.0.1",
      "nodes_dns_address" = "10.200.0.1"
    }
  }  
  "worker_vm_request"    = {
    "vm_settings" = {
      "name_label_prefix" = "deb11-k8s-worker",
      "count" = 3,
      "cpu_count" = 4,
      "memory_size_gb" = 3 * 1024 * 1024 * 1024, # GB to B,
      "labels" = {
        "ntmax.ca/cloud-platform" = "xcp-ng"
        "ntmax.ca/cloud-os"       = "debian-11-focal"
        "ntmax.ca/region"         = "mtl-south-1"
      }
      "vm_tags" = [
        "ntmax.ca/cloud-os:debian-11-focal",
        "ntmax.ca/middleware:kubernetes",
        "ntmax.ca/provisionning:ansible",
        "ntmax.ca/provisionning:terraform",
        "kubernetes.io/role:worker"
      ]
    }
    "network_settings" = {
      "node_address_mask" = "10.200.0.0",
      "node_address_start_ip" = 20,
      "node_network_dhcp" = false,
      "nodes_mask" = 247,
      "nodes_gateway" = "10.200.0.1",
      "nodes_dns_address" = "10.200.0.1"
    }
  }
  "node_storage_request" = {
    "storage" = {
      "system"   = {
        "volume"  = 16 * 1024 * 1024 * 1024, # GB to B
        "sr_ids"  = ["0714cdc3-2eea-f339-f10c-4777c715400a"]
      }
      "diskless"   = {
        "count" = 0
      }
      "ssd"   = {
        "volume"  = 8 * 1024 * 1024 * 1024, # GB to B
        "sr_ids"  = ["0714cdc3-2eea-f339-f10c-4777c715400a"],
        "count" = 2
      }
      "nvme"   = {
        "volume"  = 9 * 1024 * 1024 * 1024, # GB to B
        "sr_ids"  = ["0714cdc3-2eea-f339-f10c-4777c715400a"],
        "count" = 1
      }
      "hdd"   = {
        "volume"  = 10 * 1024 * 1024 * 1024, # GB to B
        "sr_ids"  = ["0714cdc3-2eea-f339-f10c-4777c715400a"],
        "count" = 3
      }
    }
  }
  "dns_request" = {
    "dns_key_name" = "lopati-magazin.local.",
    "dns_key_secret" = "supersecret",
    "dns_server" = "wsus.its.local",
    "dns_zone" = "its.local.",
    "dns_sub_zone" = "k8s",
    "dns_ttl" = 600 
  }
  "certificate_request" = {
    "organization"        = "lopati-magazin",
    "organizational_unit" = "Labs",
    "locality"            = "Novosibirsk",
    "country"             = "RU",
    "province"            = "NSK"
  }
  "ssh_auth_request" = {
    "vm_rsa_ssh_key" = <<EOF
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCt5+QyPfxJ6UB0aOn9HvEn9bX3HGy/6i0ibZpkJjBKAQAgV5GBgBihjCm5D2CevI7WOvBXrR6JXPgu0wQSAv9cNyi8Tpvia6IhE1Jva8Fp3JMnig1+dmhqu69goBfPNrmTO/33+GqJ6cGx80EuVsnQGnqcIIfEHo+n50ZNhKXEPzPaOCQfBjwMPXrl2mX0WBkUW3oXh7VkaYHA2mX8KgRKjgxX2Ws8uAzZ+k0N3qBUIWWzoempIIXuCGzvt9XpOjfYM+dXbbj9Ux4qqC8uPM9wnQYcMAUG0N061oClp9vJEeGvY3z01d8ISpmNAooAMcbpMj18Dzt8jogQ831bsyhzco0PEzipZQUWs3RLwTxgInyZCZFpwd/GRnkl0fHIPNbzIGjoDMIywy1CJKqa1vJLoJccNDAki2tIsUqCJXghCmbkUA+D8QA8IyNkmCDa8pDbH7/NuujvD22vpA6sp6kYF2I9KdF3nqtlyWRG0JYal8SIoiUwv2oJ3i6V2uI6Drs= n.nikitashin@nick-mgmt

      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCrSoLe1bqObD8Eh+7dhMRd66g9m3/wVqviFNdxyDLIDa89lf3o56Lvd3uLEgVrGxZxFHFApCuVuujxDRumiw7wN1R6cPgQdcKb834M8v38mmb3IokIqb/+38nPPAiEs5TR/qNkEXtajASkMGObDkhwb8uPh4B92FOvk8BHMadmNPxoVp4WJSy314At4K2EPK4DKk8O+cEVs+JwplQxLA8S6oNY7eztNcTRpF/wCJ7BUDKKMnNki2eWCjYD946RW4/LScKtTN410iVa4kW1mj50NNHCTLrxniwg9MP+xrP0Z1qf1vT8ihT3OAzLaYigK3WO9X5U1K/+Sv8MIOBxiZMSTdWwNbxk/mh98EGdluY2U5e5yWU4vC88UZElS33N/B1BiuPOzV7U+SYWMpUTE46dgNhd9ZJk2fm0lU3zY048lRAXS4tbrqKZeb4qsbkNshKqAOUpnevosBT4UAoOSHgqWo9qQmYBphD+ZqFZyKC+pmNXa1Cd40V4I+V1LM0JvQM= a.teremshonok"
    EOF
    #need to be here
    #https://github.com/terraform-linters/tflint-ruleset-aws/issues/42#issuecomment-928199917
  }
}

#Kubernetes settings
global_master_node_address_mask = "10.200.0."
global_master_node_address_start_ip = 11

global_pods_address_mask = "10.244.0.0"
#Nodes mask in CIDR format, default 16
global_pods_mask_cidr = 16
#Runtime containerd version
#https://github.com/containerd/containerd/releases
global_version_containerd = "1.7.2"
#Runtime runc library version
#https://github.com/opencontainers/runc/releases/download
global_version_runc = "1.1.7"
#CNI network plugin
#https://github.com/containernetworking/plugins/releases/download
global_version_cni-plugin = "1.3.0"
#IP address endpoint of Kubernetes cluster
global_k8s_api_endpoint_ip = "10.200.0.10"
#IP PORT endpoint of Kubernetes cluster via VRRP_HAProxy
global_k8s_api_endpoint_port = "8888"
#Make NAT for CNI pod network
global_k8s_cni_hairpinMode = true
#Make default gateway for CNI pod network
global_k8s_cni_isDefaultGateway = true
#Backend type for CNI pod network
global_k8s_cni_Backend_Type = "vxlan"
#NodePort for Kube-dashboard
global_kube-dashboard_nodePort = 30100
#SSD LVM Storage type for Linstore Thin or Thick
global_ssd_k8s_stor_pool_type = "thin"
#SSD LVM Storage name prefix for Linstore
global_ssd_k8s_stor_pool_name = "main"
#NVME LVM Storage type for Linstore Thin or Thick
global_nvme_k8s_stor_pool_type = "thin"
#NVME LVM Storage name prefix for Linstore
global_nvme_k8s_stor_pool_name = "main"
#HDD LVM Storage type for Linstore Thin or Thick
global_hdd_k8s_stor_pool_type = "thin"
#HDD LVM Storage name prefix for Linstore
global_hdd_k8s_stor_pool_name = "main"