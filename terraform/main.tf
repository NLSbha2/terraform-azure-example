
# this line is important so that backend connection is extablished in the pipeline
terraform {
  backend "azurerm" {}
}
# Configure the Microsoft Azure Provider
resource "azurerm_resource_group" "sbops-rg" {
  name     = "${var.name}-rg"
  location = var.location
  tags = {
    Environment = var.environment
  }
}
resource "azurerm_app_service_plan" "sbops" {
  name                = "azure-functions-sbops-service-plan"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.sbops-rg.name
  kind                = "FunctionApp"
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}
resource "azurerm_application_insights" "sbops" {
  name                = "sbops-test-terraform-insights"
  location            = "westeurope"
  resource_group_name = azurerm_resource_group.sbops-rg.name
  application_type    = "web"
}

resource "azurerm_storage_account" "sbopssa" {
  name                     = "sbopssatf"
  resource_group_name      = azurerm_resource_group.sbops-rg.name
  location                 = azurerm_resource_group.sbops-rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_function_app" "sbops" {
  name                      = "sbops-test-terraform"
  location                  = "westeurope"
  resource_group_name       = azurerm_resource_group.sbops-rg.name
  app_service_plan_id       = azurerm_app_service_plan.sbops.id
  storage_account_name = azurerm_storage_account.sbopssa.name
  storage_account_access_key = azurerm_storage_account.sbopssa.primary_access_key

  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.sbops.instrumentation_key
  }
}
//modules
module "acr" {
  source   = "./modules/container-registry"
  name     = "sbopsacr"
  environment = "dev"
  resourceGroupName = azurerm_resource_group.sbops-rg.name
  resourceGroupLocation = azurerm_resource_group.sbops-rg.location
}

module "redis" {
  source   = "./modules/redis-cache"
  name     = "sbops-redis"
  environment = "dev"
  resourceGroupName = azurerm_resource_group.sbops-rg.name
  resourceGroupLocation = azurerm_resource_group.sbops-rg.location
}
module "vnet" {
  source   = "./modules/vnet"
  name     = "sbops-vnet"
  environment = "dev"
  resourceGroupName = azurerm_resource_group.sbops-rg.name
  resourceGroupLocation = azurerm_resource_group.sbops-rg.location
  network_address_space = var.network_address_space
  sbops_subnet_address_name = var.sbops_subnet_address_name
  sbops_subnet_address_prefix = var.sbops_subnet_address_name
  appgw_subnet_address_name = var.subnet_address_name
  appgw_subnet_address_prefix = var.subnet_address_prefix

}

module "azuresql" {
  source   = "./modules/azure-sql"
  name     = "mysbopssql"
  environment = "dev"
  subnet = module.vnet.sbops_subnet_id
  resourceGroupName = azurerm_resource_group.sbops-rg.name
  resourceGroupLocation = azurerm_resource_group.sbops-rg.location
}