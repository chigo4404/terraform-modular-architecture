####################################################################################################
# 1. Fetch current Azure Context
data "azurerm_client_config" "current" {}

# 2. Network Security Group (Firewall)
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-${var.client_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
}

# 3. Link NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "assoc" {
  subnet_id                 = var.target_subnet_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# 4. The Key Vault (Secrets Storage)
resource "azurerm_key_vault" "kv" {
  name                        = "kv-${var.client_name}-${var.environment}" # Must be unique
  location                    = var.location
  resource_group_name         = var.rg_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
}

# 5. Give the Architect/Admin access to the Vault
resource "azurerm_key_vault_access_policy" "current_user" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id # Auto-detects YOU

  secret_permissions = ["Get", "List", "Set", "Delete", "Recover", "Purge"]
}

# 6. Store a Secret (Example: VM Password)
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-initial-password"
  value        = "ComplexPassword123!" 
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [azurerm_key_vault_access_policy.current_user]
}
