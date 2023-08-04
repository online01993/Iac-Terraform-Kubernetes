#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
#locals {
# values = [
#    for i in range(length(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents)) :
#    {
#      "id"      = i
#      "yaml"    = data.kubectl_path_documents.k8s_cni_plugin_yaml_file[i].documents
#    }
#  ]
#}    
data "kubectl_path_documents" "k8s_cni_plugin_yaml_file" {
 pattern                       = "${path.module}/scripts/kube-flannel.yml.tpl"
 vars                          = {
  pod-network-cidr             = "${var.pods_mask_cidr}"
  cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
  cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
  cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"
 } 
}
resource "kubectl_manifest" "k8s_cni_plugin" {
 depends_on                    = [
    data.kubectl_path_documents.k8s_cni_plugin_yaml_file,
    kubectl_manifest.k8s_cni_plugin
 ]
 for_each                      = toset(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents)
 #for_each = { for i in local.values : i.id => i }
 yaml_body                     = each.value.yaml
 #count                         = length(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents)
 #yaml_body                     = element(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents, count.index)
}