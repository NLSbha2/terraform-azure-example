

resource "azurerm_sql_server" "sbopsserver" {
  name                         = "${var.name}server"
  resource_group_name          = var.resourceGroupName
  location                     = var.resourceGroupLocation
  version                      = "12.0"
  administrator_login          = "admin-sc"
  administrator_login_password = "4-v3ry-53cr37-p455w0rd"

  tags = {
    environment = var.environment
  }
}

resource "azurerm_sql_database" "sbopsdb" {
  name                = "${var.name}database"
  resource_group_name          = var.resourceGroupName
  location                     = var.resourceGroupLocation
  server_name         =         azurerm_sql_server.sbopsserver.name

  tags = {
    environment = var.environment
  }
}

resource "azurerm_sql_virtual_network_rule" "sqlvnetrule" {
  name                = "sql-vnet-rule"
  resource_group_name = var.resourceGroupLocation
  server_name         = azurerm_sql_server.sbopsserver.name
  subnet_id           = var.subnet
}