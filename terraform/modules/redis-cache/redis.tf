
# NOTE: the Name used for Redis needs to be globally unique
resource "azurerm_redis_cache" "sbopsrediscache" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resourceGroupName
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}