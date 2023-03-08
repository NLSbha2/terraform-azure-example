resource "azurerm_resource_group" "sbops-rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_storage_account" "sbopssa" {
  name                     = "sbopssatftest"
  resource_group_name      = azurerm_resource_group.sbops-rg.name
  location                 = azurerm_resource_group.sbops-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    Environment = var.environment
  }
}