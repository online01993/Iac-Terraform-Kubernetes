#versions.tf
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