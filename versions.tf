#versions.tf
terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}
provider "kubernetes" {
  host               = module.kubernetes-base.k8s-url
  insecure           = false
  client_certificate = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  client_key         = base64decode(module.kubernetes-base.k8s-client-key-data)
  cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
}
provider "kubectl" {
  host               = module.kubernetes-base.k8s-url
  load_config_file   = false
  insecure           = false
  client_certificate = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  client_key         = base64decode(module.kubernetes-base.k8s-client-key-data)
  cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
}