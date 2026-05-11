resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  location            = var.location
  resource_group_name = var.rg_name
lifecycle {
  prevent_destroy = true
}

}

resource "azurerm_subnet" "subnets" {
  count                = length(var.subnet_names)
  name                 = var.subnet_names[count.index]
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet_prefixes[count.index]]
  # ADD THIS LINE:
  depends_on           = [azurerm_virtual_network.vnet]
}

output "subnet_ids" {
  value = azurerm_subnet.subnets[*].id
}



