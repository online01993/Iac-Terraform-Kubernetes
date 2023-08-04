# Instruct terraform to download the provider on `terraform init`
#terraform {
#  required_providers {
# }
#} 
terraform {
  required_providers {
    kubectl = {
      source = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}
provider "kubernetes" {
  host                    = local.k8s-url
  insecure                = true
  client_certificate      = base64decode(local.k8s-client-certificate-data)
  client_key              = base64decode(local.k8s-client-key-data)
  #cluster_ca_certificate  = base64decode(var.k8s-certificate-authority-data)
}
provider "kubectl" {
  host                    = local.k8s-url
  load_config_file        = false
  insecure                = true
  client_certificate      = base64decode(local.k8s-client-certificate-data)
  client_key              = base64decode(local.k8s-client-key-data)
  #cluster_ca_certificate  = base64decode(var.k8s-certificate-authority-data)
}