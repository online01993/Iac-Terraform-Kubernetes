#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
locals {
  crds_rendered_content = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
        pod-network-cidr             = "${var.pods_mask_cidr}"
        cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
        cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
        cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"  
    })
  #crds_split_doc  = split("---", file("${path.module}/scripts/kube-flannel.yml.tpl"))
  crds_split_doc  = split("---", local.crds_rendered_content)
  crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
  crds_dict       = { for doc in toset(local.crds_valid_yaml) : yamldecode(doc).metadata.name => doc }
}
resource "kubectl_manifest" "k8s_cni_plugin" {
  for_each  = local.crds_dict
  yaml_body = each.value
}