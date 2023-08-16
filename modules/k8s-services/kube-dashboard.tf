#kube-dashboard.tf
#https://adamtheautomator.com/kubernetes-dashboard/
/*data "kubectl_path_documents" "k8s_kube-dashboard_yaml_file" {
 pattern                       = "${path.module}/scripts/kube-dashboard.yml.tpl"
 vars                          = {
  kube-dashboard_nodePort      = "${var.kube-dashboard_nodePort}"
 }  
}
resource "kubectl_manifest" "k8s_kube-dashboard" {
 depends_on                    = [
    data.kubectl_path_documents.k8s_kube-dashboard_yaml_file,
    kubectl_manifest.k8s_cni_plugin
 ]
 for_each                      = toset(data.kubectl_path_documents.k8s_kube-dashboard_yaml_file.documents)
 yaml_body                     = each.value  
}*/
locals {
  crds_rendered_content = templatefile("${path.module}/scripts/kube-dashboard.yml.tpl", {
        kube-dashboard_nodePort      = "${var.kube-dashboard_nodePort}"
    })
  crds_split_doc  = split("---", local.crds_rendered_content)
  #crds_valid_yaml = [for doc in local.crds_split_doc : doc if try(yamldecode(doc).metadata.name, "") != ""]
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
resource "kubectl_manifest" "k8s_kube-dashboard" {
  depends_on                    = [
    kubectl_manifest.k8s_cni_plugin
 ]
 for_each  = local.crds_dict
 yaml_body = each.value.doc  
}