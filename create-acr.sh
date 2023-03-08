#!/bin/sh

ACR_RESOURCE_GROUP_NAME="sbopsimagesacr-rg"
ACR_NAME="sb-demo"

# Create a resource group to store container registry
az group create --name $ACR_RESOURCE_GROUP_NAME --location uksouth

# Create a container registry that will be where you deploy your image to
az acr create --resource-group $ACR_RESOURCE_GROUP_NAME --name $ACR_NAME --sku Basic