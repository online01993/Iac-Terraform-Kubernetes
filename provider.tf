# Instruct terraform to download the provider on `terraform init`
terraform {
  required_providers {
    xenorchestra = {
      source  = "terra-farm/xenorchestra"
      version = "~> 0.9"
    }
    rke = {
      source = "rancher/rke"
      #version = "1.4.1"
    }
    tls = {
      source = "hashicorp/tls"
      #version = "4.0.4"
    }
  #required_version = "~> 1.14"
 }
} 
# Configure the tls Provider
provider "tls" {
  # Configuration options
}
provider "xenorchestra" {
  # Must be ws or wss
  url      = var.global_xen_xoa_url      # Or set XOA_URL environment variable
  username = var.global_xen_xoa_username # Or set XOA_USER environment variable
  password = var.global_xen_xoa_password # Or set XOA_PASSWORD environment variable
  insecure = var.global_xen_xoa_insecure # Or set XOA_INSECURE environment variable to any value
}
# Configure the DNS Provider
# provider "dns" {
# update {
# server = var.dns_server
# key_name      = var.dns_key_name
# key_algorithm = "hmac-sha512"
# key_secret    = var.dns_key_secret   
# }
# alias = "bind"
# }