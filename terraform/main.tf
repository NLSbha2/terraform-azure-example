
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
resource "azurerm_function_app" "sbops" {
  name                      = "sbops-test-terraform"
  location                  = "westeurope"
  resource_group_name       = "resource_group_name"
  app_service_plan_id       = azurerm_app_service_plan.sbops.id
  storage_connection_string = "DefaultEndpointsProtocol=https;AccountName=sbdevopssta;AccountKey=fnE/WeQIKYYiZmL1lJmjicJrqtlfvLUURqnWCsg60C0Av37GvcRCCPghQJxBXIJINZJzg5AvDDFf+AStf5irmA==;EndpointSuffix=core.windows.net"
  app_settings = {
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.sbops.instrumentation_key
  }
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