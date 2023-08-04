#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
locals {
  crds_rendered_content = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr             = "${var.pods_mask_cidr}"
        cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"  
    }
  crds_valid_yaml = [for doc in local.crds_rendered_content : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
}
resource "kubectl_manifest" "k8s_cni_plugin" {
  for_each  = local.crds_dict
  yaml_body = each.value
} 
/*data "kubectl_path_documents" "k8s_cni_plugin_yaml_file" {
 pattern                       = "${path.module}/scripts/kube-flannel.yml.tpl"
 vars                          = {
  pod-network-cidr             = "${var.pods_mask_cidr}"
  cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
  cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
  cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"
 } 
}
data "kubectl_file_documents" "k8s_cni_plugin_yaml_file" {
    content = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr             = "${var.pods_mask_cidr}"
        cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"  
    }
)
}
resource "kubectl_manifest" "k8s_cni_plugin" {
# depends_on                    = [
    #data.kubectl_path_documents.k8s_cni_plugin_yaml_file
    #data.kubectl_file_documents.k8s_cni_plugin_yaml_file
 #]
 for_each                      = data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents
 yaml_body                     = each.value
 #count                         = length(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents)
 #yaml_body                     = element(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents, count.index)
 #for_each                      = {for i in toset([data.kubectl_file_documents.k8s_cni_plugin_yaml_file[i].manifests])}
 #yaml_body                     = each.value.yaml
}*/