# Instruct terraform to download the provider on `terraform init`
terraform {
  required_providers {
    xenorchestra = {
      source  = "terra-farm/xenorchestra"
      #version = "~> 0.9"
      version = "0.24.2"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
# Configure the tls Provider
provider "xenorchestra" {
  # Must be ws or wss
  url      = var.xen_xoa_url      # Or set XOA_URL environment variable
  username = var.xen_xoa_username # Or set XOA_USER environment variable
  password = var.xen_xoa_password # Or set XOA_PASSWORD environment variable
  insecure = var.xen_xoa_insecure # Or set XOA_INSECURE environment variable to any value
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