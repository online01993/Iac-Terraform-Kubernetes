module "infrastructure" {
  source = "./modules/infrastructure"
  #make linking vars from source and tfvars
  xen_infra_settings           = var.global_xen_infra_settings
}
module "kubernetes-base" {
  depends_on                   = [module.infrastructure]
  source                       = "./modules/k8s-base"
  kubernetes_infra_setup_settings           = var.global_kubernetes_infra_setup_settings
  vm_rsa_ssh_key_public        = module.infrastructure.vm_rsa_ssh_key_public
  vm_rsa_ssh_key_private       = module.infrastructure.vm_rsa_ssh_key_private
  masters                      = module.infrastructure.xen_masters
  nodes                        = module.infrastructure.xen_nodes
}
module "k8s-system-services" {
  depends_on                   = [module.kubernetes-base]
  source                       = "./modules/k8s-system-services"
  masters                      = module.infrastructure.xen_masters
  nodes                        = module.infrastructure.xen_nodes
  k8s_cni_hairpinMode          = var.global_k8s_cni_hairpinMode
  k8s_cni_isDefaultGateway     = var.global_k8s_cni_isDefaultGateway
  k8s_cni_Backend_Type         = var.global_k8s_cni_Backend_Type
  kube-dashboard_nodePort      = var.global_kube-dashboard_nodePort
  pods_mask_cidr               = "${var.global_pods_address_mask}/${var.global_pods_mask_cidr}"
  ssd_k8s_stor_pool_type       = var.global_ssd_k8s_stor_pool_type
  ssd_k8s_stor_pool_name       = var.global_ssd_k8s_stor_pool_name
  nvme_k8s_stor_pool_type      = var.global_nvme_k8s_stor_pool_type
  nvme_k8s_stor_pool_name      = var.global_nvme_k8s_stor_pool_name
  hdd_k8s_stor_pool_type       = var.global_hdd_k8s_stor_pool_type
  hdd_k8s_stor_pool_name       = var.global_hdd_k8s_stor_pool_name
}  