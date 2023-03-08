provider "azurerm" {
  features {}
  subscription_id = "b6084cf2-c818-4cac-8fc3-acf27e582135"
  skip_provider_registration = "true"

}


data "azurerm_client_config" "current" {}
