# Instruct terraform to download the provider on `terraform init`
#terraform {
#  required_providers {
# }
#} 
terraform {
  required_providers {
    kubectl = {
      source = "alekc/kubectl"
      version = "2.0.2"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}
provider "kubernetes" {
  host                    = module.kubernetes-base.k8s-url
  insecure                = true
  client_certificate      = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  client_key              = base64decode(module.kubernetes-base.k8s-client-key-data)
  #cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
}
provider "kubectl" {
  host                    = module.kubernetes-base.k8s-url
  load_config_file        = false
  insecure                = true
  client_certificate      = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  client_key              = base64decode(module.kubernetes-base.k8s-client-key-data)
  #cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
}