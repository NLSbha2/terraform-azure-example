resource "azurerm_resource_group" "kubernetes_resource_group" {
  location = var.location
  name     = "${var.name}-rg"
  tags = {
    Environment = var.environment
  }
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = var.name
  location            = var.location
  resource_group_name = azurerm_resource_group.kubernetes_resource_group.name
  dns_prefix          = var.name
  kubernetes_version  = var.kubernetes_version

  node_resource_group = "${var.name}-node-rg"

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  default_node_pool {
    name                 = "agentpool"
    node_count           = var.agent_count
    vm_size              = var.vm_size
    vnet_subnet_id       = var.aks_subnet
    type                 = "VirtualMachineScaleSets"
    orchestrator_version = var.kubernetes_version
  }

  identity {
    type = "SystemAssigned"
  }

  addon_profile {
    oms_agent {
      enabled                    = var.addons.oms_agent
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
    azure_policy {
      enabled = var.addons.azure_policy
    }

    ingress_application_gateway {
      enabled   = var.addons.ingress_application_gateway
      subnet_id = var.agic_subnet_id
    }

  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "azure"
  }


  }

  tags = {
    Environment = var.environment
  }
}

data "azurerm_resource_group" "node_resource_group" {
  name = azurerm_kubernetes_cluster.k8s.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}

resource "azurerm_role_assignment" "node_infrastructure_update_scale_set" {
  principal_id         = azurerm_kubernetes_cluster.k8s.kubelet_identity[0].object_id
  scope                = data.azurerm_resource_group.node_resource_group.id
  role_definition_name = "Virtual Machine Contributor"
  depends_on = [
    azurerm_kubernetes_cluster.k8s
  ]
}


provider "azuread" {}

data "azuread_user" "aad" {
  mail_nickname = "bruno.cochofel_gmail.com#EXT#"
}

resource "azuread_group" "k8sadmins" {
  display_name = "Kubernetes Admins"
  members = [
    data.azuread_user.aad.object_id,
  ]
}

module "rg" {
  source  = "bcochofel/resource-group/azurerm"
  version = "1.4.0"

  name     = "rg-${var.identifier}-example"
  location = var.location
}

resource "azurerm_user_assigned_identity" "main" {
  resource_group_name = module.rg.name
  location            = module.rg.location

  name = "identity-${var.identifier}-example"
}

module "vnet" {
  source  = "bcochofel/virtual-network/azurerm"
  version = "1.2.1"

  resource_group_name = module.rg.name
  name                = "vnet-${var.identifier}-example"
  address_space       = ["10.5.0.0/16"]

  depends_on = [module.rg]
}

module "subnet" {
  source  = "bcochofel/subnet/azurerm"
  version = "1.3.1"

  name                 = "snet-${var.identifier}-example"
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.5.0.0/21"]
}

resource "azurerm_private_dns_zone" "main" {
  name                = "privatelink.northeurope.azmk8s.io"
  resource_group_name = module.rg.name
}

resource "azurerm_role_assignment" "network" {
  scope                = module.rg.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

resource "azurerm_role_assignment" "dns" {
  scope                = azurerm_private_dns_zone.main.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.main.principal_id
}

module "aks" {
  source = "../.."

  name                = "aks${var.identifier}"
  resource_group_name = module.rg.name
  dns_prefix          = "demolab"

  default_pool_name = "default"

  user_assigned_identity_id = azurerm_user_assigned_identity.main.id

  enable_azure_active_directory   = true
  rbac_aad_managed                = true
  rbac_aad_admin_group_object_ids = [azuread_group.k8sadmins.object_id]

  private_dns_zone_id = azurerm_private_dns_zone.main.id

  node_resource_group = "aks-${var.identifier}-example"

  private_cluster_enabled = true

  availability_zones   = ["1", "2", "3"]
  enable_auto_scaling  = true
  max_pods             = 100
  orchestrator_version = "1.18.14"
  vnet_subnet_id       = module.subnet.id
  max_count            = 3
  min_count            = 1
  node_count           = 1

  enable_log_analytics_workspace = true

  network_plugin = "azure"
  network_policy = "calico"

  kubernetes_version = "1.18.14"

  only_critical_addons_enabled = true

  node_pools = [
    {
      name                 = "user1"
      availability_zones   = ["1", "2", "3"]
      enable_auto_scaling  = true
      max_pods             = 100
      orchestrator_version = "1.18.14"
      priority             = "Regular"
      max_count            = 3
      min_count            = 1
      node_count           = 1
    },
    {
      name                 = "spot1"
      max_pods             = 100
      orchestrator_version = "1.18.14"
      priority             = "Spot"
      eviction_policy      = "Delete"
      spot_max_price       = 0.5 # note: this is the "maximum" price
      node_labels = {
        "kubernetes.azure.com/scalesetpriority" = "spot"
      }
      node_taints = [
        "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
      ]
      node_count = 1
    }
  ]

  tags = {
    "ManagedBy" = "Terraform"
  }

  depends_on = [
    module.rg,
    azurerm_role_assignment.dns,
    azurerm_role_assignment.network
  ]
}