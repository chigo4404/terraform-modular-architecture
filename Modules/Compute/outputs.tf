output "private_ip_addresses" {
  description = "The private IP addresses of all VMs created"
  # This uses the '*' splat operator to get the IPs of all 'count' instances
  value       = azurerm_network_interface.nic[*].private_ip_address
}

/*
output "vm_id" {
  value = azurerm_linux_virtual_machine.vm.id
}
*/


output "vm_id" {
  description = "The IDs of all VMs created"
  value       = azurerm_linux_virtual_machine.vm[*].id
}