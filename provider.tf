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
  }
    tls = {
      source = "hashicorp/tls"
      #version = "4.0.4"
    }
  #required_version = "~> 1.14"
}
# Configure the tls Provider
provider "tls" {
  # Configuration options
}