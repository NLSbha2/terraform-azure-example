

variable "name" {
}

variable "location" {
  default = "westeurope"
}


variable "kubernetes_version" {
}

variable "agent_count" {
}

variable "vm_size" {
}

variable "dns_prefix" {
  default = "sbopsdns"
}

variable "kubernetes_cluster_rbac_enabled" {
  default = "true"
}


variable "addons" {
  description = "Defines which addons will be activated."
  type = object({
    oms_agent            = bool
    azure_policy         = bool
    ingress_application_gateway = bool
  })
}

variable log_analytics_workspace_id {
}

variable aks_subnet {
}

variable agic_subnet_id {
}

variable "environment" {
}