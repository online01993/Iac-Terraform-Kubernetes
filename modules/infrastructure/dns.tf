#Create a DNS A record set
# resource "dns_a_record_set" "nodes" {
# provider = dns.bind
# count     = var.node_count
# zone      = "${var.dns_sub_zone}.${var.dns_zone}"
# name      = "${xenorchestra_vm.vm[count.index].name_label}"
# addresses = xenorchestra_vm.vm[count.index].ipv4_addresses
# ttl       = 3600
# }
# resource "dns_cname_record" "nodes" {
# provider = dns.bind
# count = var.node_count
# zone  = "${var.dns_sub_zone}.${var.dns_zone}"
# name  = "node-${count.index}"
# cname = "${xenorchestra_vm.vm[count.index].name_label}.${var.dns_sub_zone}.${var.dns_zone}"
# ttl   = 900
# }
# # Create a DNS A record set
# resource "dns_a_record_set" "masters" {
# provider = dns.bind
# count     = var.master_count
# zone      = "${var.dns_sub_zone}.${var.dns_zone}."
# name      = "${xenorchestra_vm.vm_master[count.index].name_label}"
# addresses = xenorchestra_vm.vm_master[count.index].ipv4_addresses
# ttl       = 3600
# }
# resource "dns_cname_record" "masters" {
# provider = dns.bind
# count = var.master_count
# zone  = "${var.dns_sub_zone}.${var.dns_zone}."
# name  = "master-${count.index}"
# cname = "${xenorchestra_vm.vm_master[count.index].name_label}.${var.dns_sub_zone}.${var.dns_zone}"
# ttl   = 900
# }
# resource "dns_a_record_set" "controlplane" {
# provider = dns.bind
# zone      = "${var.dns_sub_zone}.${var.dns_zone}"
# name      = "controlplane"
# addresses = xenorchestra_vm.vm_master[*].ipv4_addresses[0]
# ttl       = 3600
# }
