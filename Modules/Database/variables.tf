
/*
variable "db_name" {
  type        = string
  description = "The name of the SQL Database"
}

variable "rg_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "admin_user" {
  type        = string
  description = "Administrator login name"
}

variable "admin_password" {
  type        = string
  sensitive   = true
  description = "Administrator password"
}

*/


variable "rg_name" {}
variable "location" {}
variable "db_name" {}
variable "admin_user" {}
variable "admin_password" {}


variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources"
  default     = {}
}

# This variable allows the Database module to link to the Log Analytics Workspace created in the Monitoring module for enhanced diagnostics and monitoring capabilities.
variable "log_analytics_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace for diagnostics"
}

