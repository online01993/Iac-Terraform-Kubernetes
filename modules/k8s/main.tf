#main.tf
template = templatefile("./modules/infrastructure/cloud_config.tftpl", {
    hostname       = "deb11-k8s-${random_uuid.vm_master_id[count.index].result}.${lower(var.dns_sub_zone)}.${substr(lower(var.dns_zone), 0, length(var.dns_zone) - 1)}"
    vm_rsa_ssh_key = "${var.vm_rsa_ssh_key}"
  })
  
resource "terraform_data" "01-k8s-base-setup" {
  triggers_replace = [
    aws_instance.web.id,
    aws_instance.database.id
  ]

  provisioner "local-exec" {
    command = "bootstrap-hosts.sh"
  }
}