variable "client_name" {
  type        = string
  description = "The name of the client (used for naming convention)"
}

variable "environment" {
  type        = string
  description = "dev, staging, or prod"
}

variable "location" {
  type        = string
  description = "Azure region for the Key Vault and NSG"
}

variable "rg_name" {
  type        = string
  description = "The Resource Group where security resources will live"
}

variable "target_subnet_id" {
  type        = string
  description = "The ID of the subnet to attach the NSG to"
}


variable "admin_object_id" {
  type        = string
  description = "The Azue AD Object ID of the user who needs access"
}

variable "tenant_id" {
  type        = string
  description = "The Azure Tenant ID"
}
