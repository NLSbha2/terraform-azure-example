variable "name" {
  type        = string
  description = "What's in a name? everything"
}

variable "location" {
  type        = string
  description = "Location of Resources"
  default = "westeurope"
}
variable "environment" {
  type        = string
  description = "Environment"
}

variable "resourceGroupName" {
}
variable "resourceGroupLocation" {
}