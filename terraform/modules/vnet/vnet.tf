resource "azurerm_virtual_network" "sbops_virtual_network" {
  name = var.name
  location = var.location
  resource_group_name = var.resourceGroupName
  address_space = [var.network_address_space]
  tags = {
    Environment = var.environment
  }

}

resource "azurerm_subnet" "sbopssubnet" {
  name = var.aks_subnet_address_name
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.sbops_virtual_network.name
  address_prefixes = [var.aks_subnet_address_prefix]
}

resource "azurerm_subnet" "appgw_subnet" {
  name = var.appgw_subnet_address_name
  resource_group_name  = var.resourceGroupName
  virtual_network_name = azurerm_virtual_network.sbops_virtual_network.name
  address_prefixes = [var.appgw_subnet_address_prefix]
}