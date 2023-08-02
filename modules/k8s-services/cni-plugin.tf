#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
resource "kubectl_manifest" "k8s_cni_plugin" {
 yaml_body = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
  pod-network-cidr             = "${var.pods_mask_cidr}"
  cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
  cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
  cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"
  })
}