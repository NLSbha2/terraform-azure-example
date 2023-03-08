output "sbops_subnet_id" {
  value = azurerm_subnet.sbopssubnet.id
}

output "appgw_subnet_id" {
  value = azurerm_subnet.appgw_subnet.id
}

output "vnet_id" {
  value = azurerm_virtual_network.sbops_virtual_network.id
}

output "vnet_name" {
  value = azurerm_virtual_network.sbops_virtual_network.name
}

