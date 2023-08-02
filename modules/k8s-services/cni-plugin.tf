#cni-plugin.tf
#kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
resource "kubectl_manifest" "kbs_cni_plugin_namespace" {
    yaml_body = <<YAML
kind: Namespace
apiVersion: v1
metadata:
  name: kube-flannel
  labels:
    k8s-app: flannel
    pod-security.kubernetes.io/enforce: privileged  
YAML
}
resource "kubectl_manifest" "k8s_cni_plugin" {
 depends_on                    = [kubectl_manifest.kbs_cni_plugin_namespace]
 yaml_body = templatefile("${path.module}/scripts/kube-flannel.yml.tpl", {
  pod-network-cidr             = "${var.pods_mask_cidr}"
  cni_hairpinMode              = "${var.k8s_cni_hairpinMode}"
  cni_isDefaultGateway         = "${var.k8s_cni_isDefaultGateway}"
  cni_Backend_Type             = "${var.k8s_cni_Backend_Type}"
  })
}