
variable "rg_name" {}
variable "location" {}
variable "vnet_name" {}
variable "address_space" {}
variable "subnet_names" { type = list(string) }
variable "subnet_prefixes" { type = list(string) }

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all resources"
  default     = {}
}

/*
variable "address_space" {
  type        = string
  description = "The address space for the Virtual Network"
}

variable "vnet_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "rg_name" {
  type        = string
}

variable "subnet_names" {
  type        = list(string)
}

variable "subnet_prefixes" {
  type        = list(string)
}
*/