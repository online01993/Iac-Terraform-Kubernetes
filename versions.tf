#versions.tf
terraform {
  required_providers {
    xenorchestra = {
      source  = "${var.global_provider_xenorchestra_source}"
      version = "${var.global_provider_xenorchestra_version}"
    }
    tls = {
      source  = "${var.global_provider_tls_source}"
      version = "${var.global_provider_tls_version}"
    }
    kubectl = {
      source  = "${var.global_provider_kubectl_source}"
      version = "${var.global_provider_kubectl_version}"
    }
    kubernetes = {
      source  = "${var.global_provider_kubernetes_source}"
      version = "${var.global_provider_kubernetes_version}"
    }
  }
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
provider "kubernetes" {
  host                    = module.kubernetes-base.k8s-url
  insecure                = false
  client_certificate      = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  client_key              = base64decode(module.kubernetes-base.k8s-client-key-data)
  cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
}
provider "kubectl" {
  host                    = module.kubernetes-base.k8s-url
  load_config_file        = false
  insecure                = false
  client_certificate      = base64decode(module.kubernetes-base.k8s-client-certificate-data)
  client_key              = base64decode(module.kubernetes-base.k8s-client-key-data)
  cluster_ca_certificate  = base64decode(module.kubernetes-base.k8s-certificate-authority-data)
}