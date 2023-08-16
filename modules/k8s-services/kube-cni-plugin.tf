#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
locals {
  crds_rendered_content = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr             = "${var.pods_mask_cidr}"
        cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"  
    })
  #crds_split_doc  = split("---", local.crds_rendered_content)
  crds_split_doc  = split("---", data.kubectl_file_documents.docs)
  crds_valid_yaml = [
    for i in range(length(local.crds_split_doc)) : 
    {
      "id" = i
      "doc" = local.crds_split_doc[i]      
    }
    if try(yamldecode(i).metadata.name, "") != ""
  ]
  #crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
  crds_dict       = { for i in toset(local.crds_valid_yaml) : i.id => i }
}
data "kubectl_file_documents" "docs" {
    content = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr             = "${var.pods_mask_cidr}"
        cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"  
    })
}
resource "kubectl_manifest" "k8s_cni_plugin" {
  #for_each  = local.crds_dict
  for_each  = { for i in toset(local.crds_valid_yaml) : i.id => i }
  yaml_body = each.value.doc
}