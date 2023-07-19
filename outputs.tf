# output "nodes_ips" {
  # value = module.infrastructure.nodes_ips
# }

# output "nodes" {
  # value = module.infrastructure.nodes
# }

# output "masters_ips" {
  # value = module.infrastructure.masters_ips
# }

# output "masters" {
  # value = module.infrastructure.masters
# }
# output "masters" {
  # value = tomap({
    # "fqdn"    = xenorchestra_vm.vm_master[*].name_label
	# "address" = xenorchestra_vm.vm_master[*].ipv4_addresses[0]
	# })
# }
# output "nodes" {
  # value = tomap({
    # "fqdn"    = xenorchestra_vm.vm[*].name_label
	# "address" = xenorchestra_vm.vm[*].ipv4_addresses[0]
	# })
# }