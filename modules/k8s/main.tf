#main.tf
resource "terraform_data" "k8s-base-setup_01_resource_masters" {
  #for_each = module.infrastructure.masters
  for_each = { for i in var.masters: i.id => i }
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
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
  #for_each = module.infrastructure.nodes
  for_each = { for i in var.nodes: i.id => i }
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
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
  depends_on = [ 
      terraform_data.k8s-base-setup_01_resource_masters 
  ]
  for_each = { for i in var.masters: i.id => i }
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
      host     = each.value.address
    }
  provisioner "file" {
    destination = "/tmp/02-k8s-kubeadm_init.sh"
    content = templatefile("${path.module}/scripts/02-k8s-kubeadm_init.sh.tpl", {
        itterator             = each.value.id
        master_count          = "${var.master_count}"
        pod-network-cidr      = "${var.pods_address_mask}/${var.pods_mask_cidr}"
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
resource "terraform_data" "k8s-kubeadm_init_token_join_master_03_resource" {
  triggers_replace = [
    terraform_data.k8s-base-setup_01_resource_masters
  ]
  depends_on = [ 
      terraform_data.k8s-kubeadm_init_02_resource 
  ]
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_token_master_join.sh
      echo "${var.vm_rsa_ssh_key_private}" > ./.robot_id_rsa_master.key
      ssh robot@${var.masters[0].address} -o StrictHostKeyChecking=no -i ./.robot_id_rsa_master.key "(sudo kubeadm token create --print-join-command && echo ' --control-plane --certificate-key ' && sudo kubeadm init phase upload-certs --upload-certs | grep -v '^[\[]') | tr -d '\n'" > ${path.module}/scripts/k8s-kubeadm_init_token_master_join.sh
      rm -rvf ./.robot_id_rsa_master.key
    EOF
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_token_master_join.sh
    EOF
  }
}
data "local_sensitive_file" "kubeadm_token_master_file" {
  depends_on = [ 
      terraform_data.k8s-kubeadm_init_token_join_master_03_resource 
  ]
  filename = "${path.module}/scripts/k8s-kubeadm_init_token_master_join.sh"
}
resource "terraform_data" "k8s-kubeadm_init_token_join_node_03_resource" {
  triggers_replace = [
    terraform_data.k8s-base-setup_01_resource_nodes
  ]
  depends_on = [ 
      terraform_data.k8s-kubeadm_init_02_resource 
  ]
  provisioner "local-exec" {
    command = <<EOF
      sleep 30
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_token_join.sh
      echo "${var.vm_rsa_ssh_key_private}" > ./.robot_id_rsa_node.key
      ssh robot@${var.masters[0].address} -o StrictHostKeyChecking=no -i ./.robot_id_rsa_node.key "sudo kubeadm token create --print-join-command" > ${path.module}/scripts/k8s-kubeadm_init_token_join.sh
      rm -rvf ./.robot_id_rsa_node.key
    EOF
  }
  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_token_join.sh
    EOF
  }
}
data "local_sensitive_file" "kubeadm_token_node_file" {
  depends_on = [ 
      terraform_data.k8s-kubeadm_init_token_join_node_03_resource 
  ]
  filename = "${path.module}/scripts/k8s-kubeadm_init_token_join.sh"
}
resource "terraform_data" "k8s-kubeadm-join_masters_04_resource" {
  #for_each = module.infrastructure.masters
  for_each = { for i in var.masters: i.id => i }
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
	  host     = each.value.address
    }
  provisioner "file" {
    destination = "/tmp/04-k8s-kubeadm-join_masters.sh"
    content = templatefile("${path.module}/scripts/04-k8s-kubeadm-join_masters.sh.tpl", {
        kubeadm-join_string = "${data.local_sensitive_file.kubeadm_token_master_file.content}"
        master_count = "${var.master_count}"
        itterator = each.value.id
    })
  } 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/04-k8s-kubeadm-join_masters.sh",
      "/tmp/04-k8s-kubeadm-join_masters.sh",
      "rm -rf /tmp/04-k8s-kubeadm-join_masters.sh",
    ]
  }
}
resource "terraform_data" "k8s-kubeadm-join_nodes_04_resource" {
  #for_each = module.infrastructure.nodes
  for_each = { for i in var.nodes: i.id => i }
  connection {
      type     = "ssh"
      user     = "robot"
      private_key = "${var.vm_rsa_ssh_key_private}"
	  host     = each.value.address
    }
  provisioner "file" {
    destination = "/tmp/04-k8s-kubeadm-join_nodes.sh"
    content = templatefile("${path.module}/scripts/04-k8s-kubeadm-join_nodes.sh.tpl", {
        kubeadm-join_string = "${data.local_sensitive_file.kubeadm_token_node_file.content}"        
        itterator = each.value.id
    })
  } 
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/04-k8s-kubeadm-join_nodes.sh",
      "/tmp/04-k8s-kubeadm-join_nodes.sh",
      "rm -rf /tmp/04-k8s-kubeadm-join_nodes.sh",
    ]
  }
}