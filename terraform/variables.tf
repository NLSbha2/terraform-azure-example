variable "name" {
  type        = string
  description = "What's in a name? everything"
}
variable "prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "location" {
  type        = string
  description = "Location of Resources"
}
variable "environment" {
  type        = string
  description = "Environment"
}

variable "network_address_space" {
}

variable "sbops_subnet_address_prefix" {
}

variable "sbops_subnet_address_name" {
}

variable "subnet_address_prefix" {
}

variable "subnet_address_name" {
}