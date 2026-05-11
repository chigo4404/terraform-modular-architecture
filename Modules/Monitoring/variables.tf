variable "client_name" {}
variable "environment" {}
variable "location"    {}
variable "rg_name"     {}
variable "admin_email" {
  type        = string
  description = "The email address of the administrator"
}
variable "rg_id" {
  type        = string
  description = "The ID of the resource group where monitoring resources will be deployed" 
}
variable "budget_amount" {
  type        = number
  description = "The amount for the budget in USD"
  
}

variable "sql_database_id" {
  description = "The resource ID of the SQL database"
  type        = string
}
/*
variable "vm_id" {
  description = "The ID of the VM to monitor"
  type        = string
}
*/


variable "vm_ids" {
  description = "List of VM IDs to monitor"
  type        = list(string)
}


variable "log_analytics_id" {
  type = string
}