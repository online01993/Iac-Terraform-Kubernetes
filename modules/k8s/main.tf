#main.tf
resource "terraform_data" "k8s-base-setup_01_resource_masters" {
  count = "${length(var.masters)}"
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
      host     = "${values(var.masters[count.index].address)}"
    }
  provisioner "file" {
    destination = "/tmp/01-k8s-base-setup.sh"
    content = templatefile("scripts/01-k8s-base-setup.sh.tpl", {
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
  count = "${length(var.nodes)}"
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
      host     = "${values(var.nodes[count.index].address)}"
    }
  provisioner "file" {
    destination = "/tmp/01-k8s-base-setup.sh"
    content = templatefile("scripts/01-k8s-base-setup.sh.tpl", {
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
      k8s-base-setup_01_resource_masters 
  ]
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
      host     = var.Master0_VM_IP
    }
  provisioner "file" {
    destination = "/tmp/02-k8s-kubeadm_init.sh"
    content = templatefile("scripts/02-k8s-kubeadm_init.sh.tpl", {
        consul_version = "${local.consul_version}"
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