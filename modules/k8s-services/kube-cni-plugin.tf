#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
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
    data.kubectl_path_documents.k8s_cni_plugin_yaml_file
 ]
 for_each                      = tomap(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents)
 yaml_body                     = each.value  
 #count                         = length(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents)
 #yaml_body                     = element(data.kubectl_path_documents.k8s_cni_plugin_yaml_file.documents, count.index)
}