resource "azurerm_container_registry" "acr" {
  name                = "${var.name}acr"
  resource_group_name = var.resourceGroupName
  location            = var.resourceGroupLocation
  sku                 = "Premium"
  admin_enabled       = false

  tags = {
    Environment = var.environment
  }
}