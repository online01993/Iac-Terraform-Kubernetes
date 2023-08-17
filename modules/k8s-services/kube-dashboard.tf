#kube-dashboard.tf
#https://adamtheautomator.com/kubernetes-dashboard/
/*locals {
  crds_rendered_content_1 = templatefile("${path.module}/scripts/kube-dashboard.yml.tpl", {
        kube-dashboard_nodePort      = "${var.kube-dashboard_nodePort}"
    })
  crds_split_doc_1  = split("---", local.crds_rendered_content_1)
  crds_valid_yaml_1 = [
    for i in range(length(local.crds_split_doc_1)) : 
    {
      "id" = i
      "doc" = local.crds_split_doc_1[i]      
    }
    #if try(yamldecode(i).metadata.name, "") != ""
  ]
  crds_dict_1       = { for i in toset(local.crds_valid_yaml_1) : i.id => i }
}
resource "kubectl_manifest" "k8s_kube-dashboard" {
  depends_on                    = [
    kubectl_manifest.k8s_cni_plugin
 ]
 for_each  = local.crds_dict_1
 yaml_body = each.value.doc  
}*/