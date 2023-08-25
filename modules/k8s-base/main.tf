#main.tf
resource "terraform_data" "k8s-base-setup_01_resource_masters" {
  #for_each = module.infrastructure.masters
  for_each = { for i in var.masters : i.id => i }
  connection {
    type        = "ssh"
    user        = "robot"
    private_key = var.vm_rsa_ssh_key_private
    host        = each.value.address
  }
  provisioner "remote-exec" {
    inline = [<<EOF
      #cloud-init-wait 
      while [ ! -f /var/lib/cloud/instance/boot-finished ]; do 
      echo -e "\033[1;36mWaiting for cloud-init..."
      sleep 10
      done
      (sleep 5 && sudo shutdown -r now)&
      EOF
    ]
  }
  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "file" {
    destination = "/tmp/01-k8s-base-setup.sh"
    content = templatefile("${path.module}/scripts/01-k8s-base-setup.sh.tpl", {
      version_containerd = "${var.version_containerd}"
      version_runc       = "${var.version_runc}"
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
  for_each = { for i in var.nodes : i.id => i }
  connection {
    type        = "ssh"
    user        = "robot"
    private_key = var.vm_rsa_ssh_key_private
    host        = each.value.address
  }
  provisioner "remote-exec" {
    inline = [<<EOF
      #cloud-init-wait 
      while [ ! -f /var/lib/cloud/instance/boot-finished ]; do 
      echo -e "\033[1;36mWaiting for cloud-init..."
      sleep 10
      done
      (sleep 5 && sudo shutdown -r now)&
      EOF
    ]
  }
  provisioner "local-exec" {
    command = "sleep 60"
  }
  provisioner "file" {
    destination = "/tmp/01-k8s-base-setup.sh"
    content = templatefile("${path.module}/scripts/01-k8s-base-setup.sh.tpl", {
      version_containerd = "${var.version_containerd}"
      version_runc       = "${var.version_runc}"
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
resource "random_password" "k8s-vrrp_random_pass_resource" {
  length  = 12
  special = false
  numeric = true
}
resource "terraform_data" "k8s-kubeadm_init_02_resource" {
  depends_on = [
    terraform_data.k8s-base-setup_01_resource_masters
  ]
  for_each = { for i in var.masters : i.id => i }
  connection {
    type        = "ssh"
    user        = "robot"
    private_key = var.vm_rsa_ssh_key_private
    host        = each.value.address
  }
  provisioner "file" {
    destination = "/tmp/02-k8s-kubeadm_init.sh"
    content = templatefile("${path.module}/scripts/02-k8s-kubeadm_init.sh.tpl", {
      itterator                    = each.value.id
      master_count                 = "${var.master_count}"
      master_network_mask          = "${var.master_node_address_mask}"
      master_node_address_start_ip = "${var.master_node_address_start_ip}"
      pod-network-cidr             = "${var.pods_mask_cidr}"
      k8s_api_endpoint_ip          = "${var.k8s_api_endpoint_ip}"
      k8s_api_endpoint_port        = "${var.k8s_api_endpoint_port}"
      k8s-vrrp_random_pass         = "${random_password.k8s-vrrp_random_pass_resource.result}"
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
resource "terraform_data" "k8s-kubeadm_init_02_config_get_resource" {
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_resource
  ]
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_02_config_file.conf
      echo "${var.vm_rsa_ssh_key_private}" > ./.robot_id_rsa_master_config_file.key
      chmod 600 ./.robot_id_rsa_master_config_file.key
      ssh robot@${var.masters[0].address} -o StrictHostKeyChecking=no -i ./.robot_id_rsa_master_config_file.key "cat /home/robot/.kube/config" > ${path.module}/scripts/k8s-kubeadm_init_02_config_file.conf
      rm -rvf ./.robot_id_rsa_master_config_file.key
    EOF
  }
}
data "local_sensitive_file" "k8s-kubeadm_init_02_config_file" {
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_config_get_resource
  ]
  filename = "${path.module}/scripts/k8s-kubeadm_init_02_config_file.conf"
}
resource "terraform_data" "k8s-kubeadm_init_02_config_get_client-key-data_resource" {
  depends_on = [
    data.local_sensitive_file.k8s-kubeadm_init_02_config_file
  ]
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-key-data_file
      cat ${path.module}/scripts/k8s-kubeadm_init_02_config_file.conf | grep client-key-data | sed 's/^\s*client-key-data: //' > ${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-key-data_file
      chmod 600 ${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-key-data_file
    EOF
  }
}
data "local_sensitive_file" "k8s-kubeadm_init_02_config_get_client-key-data_file" {
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_config_get_client-key-data_resource
  ]
  filename = "${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-key-data_file"
}
resource "terraform_data" "k8s-kubeadm_init_02_config_get_client-certificate-data_resource" {
  depends_on = [
    data.local_sensitive_file.k8s-kubeadm_init_02_config_file
  ]
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-certificate-data_file
      cat ${path.module}/scripts/k8s-kubeadm_init_02_config_file.conf | grep client-certificate-data | sed 's/^\s*client-certificate-data: //' > ${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-certificate-data_file
      chmod 600 ${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-certificate-data_file
    EOF
  }
}
data "local_sensitive_file" "k8s-kubeadm_init_02_config_get_client-certificate-data_file" {
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_config_get_client-certificate-data_resource
  ]
  filename = "${path.module}/scripts/k8s-kubeadm_init_02_config_get_client-certificate-data_file"
}
resource "terraform_data" "k8s-kubeadm_init_02_config_get_certificate-authority-data_resource" {
  depends_on = [
    data.local_sensitive_file.k8s-kubeadm_init_02_config_file
  ]
  provisioner "local-exec" {
    command = <<EOF
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_02_config_get_certificate-authority-data_file
      cat ${path.module}/scripts/k8s-kubeadm_init_02_config_file.conf | grep certificate-authority-data | sed 's/^\s*certificate-authority-data: //' > ${path.module}/scripts/k8s-kubeadm_init_02_config_get_certificate-authority-data_file
      chmod 600 ${path.module}/scripts/k8s-kubeadm_init_02_config_get_certificate-authority-data_file
    EOF
  }
}
data "local_sensitive_file" "k8s-kubeadm_init_02_config_get_certificate-authority-data_file" {
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_config_get_certificate-authority-data_resource
  ]
  filename = "${path.module}/scripts/k8s-kubeadm_init_02_config_get_certificate-authority-data_file"
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
      chmod 600 ./.robot_id_rsa_master.key
      ssh robot@${var.k8s_api_endpoint_ip} -o StrictHostKeyChecking=no -i ./.robot_id_rsa_master.key "(sudo kubeadm token create --print-join-command && echo ' --control-plane --certificate-key ' && sudo kubeadm init phase upload-certs --upload-certs | grep -v '^[\[]') | tr -d '\n'" > ${path.module}/scripts/k8s-kubeadm_init_token_master_join.sh
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
      rm -rvf ${path.module}/scripts/k8s-kubeadm_init_token_join.sh
      echo "${var.vm_rsa_ssh_key_private}" > ./.robot_id_rsa_node.key
      chmod 600 ./.robot_id_rsa_node.key
      ssh robot@${var.k8s_api_endpoint_ip} -o StrictHostKeyChecking=no -i ./.robot_id_rsa_node.key "sudo kubeadm token create --print-join-command" > ${path.module}/scripts/k8s-kubeadm_init_token_join.sh
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
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_resource,
    data.local_sensitive_file.kubeadm_token_master_file
  ]
  #for_each = module.infrastructure.masters
  for_each = { for i in var.masters : i.id => i }
  connection {
    type        = "ssh"
    user        = "robot"
    private_key = var.vm_rsa_ssh_key_private
    host        = each.value.address
  }
  provisioner "file" {
    destination = "/tmp/04-k8s-kubeadm-join_masters.sh"
    content = templatefile("${path.module}/scripts/04-k8s-kubeadm-join_masters.sh.tpl", {
      kubeadm-join_string = "${data.local_sensitive_file.kubeadm_token_master_file.content}"
      master_count        = "${var.master_count}"
      itterator           = each.value.id
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
  depends_on = [
    terraform_data.k8s-kubeadm_init_02_resource,
    data.local_sensitive_file.kubeadm_token_node_file
  ]
  #for_each = module.infrastructure.nodes
  for_each = { for i in var.nodes : i.id => i }
  connection {
    type        = "ssh"
    user        = "robot"
    private_key = var.vm_rsa_ssh_key_private
    host        = each.value.address
  }
  provisioner "file" {
    destination = "/tmp/04-k8s-kubeadm-join_nodes.sh"
    content = templatefile("${path.module}/scripts/04-k8s-kubeadm-join_nodes.sh.tpl", {
      kubeadm-join_string = "${data.local_sensitive_file.kubeadm_token_node_file.content}"
      itterator           = each.value.id
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