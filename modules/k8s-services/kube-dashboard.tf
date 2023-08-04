#kube-dashboard.tf
#https://adamtheautomator.com/kubernetes-dashboard/
data "kubectl_path_documents" "k8s_kube-dashboard_yaml_file" {
 pattern                       = "${path.module}/scripts/kube-dashboard.yml.tpl"
 vars                          = {
  kube-dashboard_nodePort      = "${var.kube-dashboard_nodePort}"
 }  
}
resource "kubectl_manifest" "k8s_kube-dashboard" {
 depends_on                    = [
    data.kubectl_path_documents.k8s_kube-dashboard_yaml_file,
    #kubectl_manifest.k8s_cni_plugin
    kubernetes_manifest.daemonset_kube_flannel_kube_flannel_ds
 ]
 for_each                      = toset(data.kubectl_path_documents.k8s_kube-dashboard_yaml_file.documents)
 yaml_body                     = each.value  
}