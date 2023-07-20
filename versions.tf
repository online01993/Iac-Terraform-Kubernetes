# Instruct terraform to download the provider on `terraform init`
terraform {
  required_providers {
    tls = {
      source = "hashicorp/tls"
    }
 }
} 
# Configure the tls Provider
provider "tls" {
  # Configuration options
}