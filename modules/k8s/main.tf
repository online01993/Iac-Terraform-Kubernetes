#main.tf
resource "terraform_data" "k8s-base-setup_01_resource_masters" {
  #count = "${length(var.masters)}"
  #for_each = module.infrastructure.masters
  for_each = { for i in var.masters: i.id => i }
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
      #host     = "${var.masters[count.index].address}"
	  host     = each.value.address
    }
  provisioner "file" {
    destination = "/tmp/01-k8s-base-setup.sh"
    content = templatefile("${path.module}/scripts/01-k8s-base-setup.sh.tpl", {
        version_containerd = "${var.version_containerd}"
        version_runc = "${var.version_runc}"
        version_cni-plugin = "${var.version_cni-plugin}"
    })
  } 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/01-k8s-base-setup.sh",
      "/tmp/01-k8s-base-setup.sh",
      "rm -rf /tmp/01-k8s-base-setup.sh",
    ]
  }
}
resource "terraform_data" "k8s-base-setup_01_resource_nodes" {
  #count = "${length(var.nodes)}"
  #for_each = module.infrastructure.nodes
  for_each = { for i in var.nodes: i.id => i }
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
      #host     = "${var.nodes[count.index].address}"
	  host     = each.value.address
    }
  provisioner "file" {
    destination = "/tmp/01-k8s-base-setup.sh"
    content = templatefile("${path.module}/scripts/01-k8s-base-setup.sh.tpl", {
        version_containerd = "${var.version_containerd}"
        version_runc = "${var.version_runc}"
        version_cni-plugin = "${var.version_cni-plugin}"
    })
  } 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/01-k8s-base-setup.sh",
      "/tmp/01-k8s-base-setup.sh",
      "rm -rf /tmp/01-k8s-base-setup.sh",
    ]
  }
}
resource "terraform_data" "k8s-kubeadm_init_02_resource" {
  #count = var.02-k8s-kubeadm_init == false ? 1 : 0
  #triggers_replace = [
  #  var.02-k8s-kubeadm_init
  #]
  #input = var.02-k8s-kubeadm_init
  depends_on = [ 
      terraform_data.k8s-base-setup_01_resource_masters 
  ]
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
      host     = "${var.masters[0].address}"
    }
  provisioner "file" {
    destination = "/tmp/02-k8s-kubeadm_init.sh"
    content = templatefile("${path.module}/scripts/02-k8s-kubeadm_init.sh.tpl", {
        vm_rsa_ssh_key = "${var.vm_rsa_ssh_key_private}"
    })
  } 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/02-k8s-kubeadm_init.sh",
      "/tmp/02-k8s-kubeadm_init.sh",
      "rm -rf /tmp/02-k8s-kubeadm_init.sh",
    ]
  }
}