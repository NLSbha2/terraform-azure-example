provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "sbops-rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}
# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "sbopscache" {
  name                = "example-cache"
  location            = azurerm_resource_group.sbops-rg.location
  resource_group_name = azurerm_resource_group.sbops-rg.name
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}