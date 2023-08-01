#versions.tf
terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.22.0"
    }
  }
}

provider "kubernetes" {
  # Configuration options
  host        = "${var.k8s-url}"
  config_path = "${var.k8s-admin_file}"
  #config_path = "~/.kube/config"
  #client_certificate     = file("~/.kube/client-cert.pem")
  #client_key             = file("~/.kube/client-key.pem")
  #cluster_ca_certificate = file("~/.kube/cluster-ca-cert.pem")
}