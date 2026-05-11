
/*
variable "rg_name"         { type = string }
variable "location"        { type = string }
variable "vm_count"        { type = number }
variable "vm_name"         { type = string }
variable "sku"             { type = string }
variable "subnet_id"       { type = string }
variable "ssh_public_key"  { type = string }
*/



variable "vm_count" {}
variable "vm_name" {}
variable "sku" {}
variable "subnet_id" {}
variable "rg_name" {}
variable "location" {}
variable "ssh_public_key" {}



variable "log_analytics_id" {
  type        = string
  description = "The ID of the Log Analytics Workspace for VM diagnostics"
}
