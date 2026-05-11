# 1. Fetch Subscription Data
data "azurerm_subscription" "current" {}

/* ##temporarily commenting out the tag policy to avoid deployment issues while testing other policies. Uncomment when ready to enforce tags.
# 2. Definition: Require Tags
resource "azurerm_policy_definition" "require_tags" {
  name         = "require-tags"
  policy_type  = "Custom"
  mode         = "Indexed"
  display_name = "Require Tags on Resources"

  policy_rule = jsonencode({
    if = {
      anyOf = [
        { field = "tags['environment']", exists = false },
        { field = "tags['owner']",       exists = false }
      ]
    }
    then = { effect = "deny" } # ARCHITECT FIX: Changed 'allow' to 'deny'
  })
}

# 3. Assignment: Apply the Tag Policy to the Subscription
resource "azurerm_subscription_policy_assignment" "audit_tags" {
  name                 = "tag-enforcement"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.require_tags.id
  location             = var.location
}
*/
# 4. Definition: Deny Public IPs
resource "azurerm_policy_definition" "deny_public_ip" {
  name         = "deny-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny Public IP creation"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Network/publicIPAddresses"
    }
    then = { effect = "deny" }
  })
}

# 5. Assignment: Apply Public IP Deny to the Subscription
resource "azurerm_subscription_policy_assignment" "block_public_ips" {
  name                 = "public-ip-block"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = azurerm_policy_definition.deny_public_ip.id
  location             = var.location
}

# policy that denies attaching public IPs in subscription. modify similar to the above before uncomenting
/*
resource "azurerm_policy_definition" "deny_nic_with_public_ip" {
  name         = "deny-nic-public-ip"
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Deny NICs with Public IPs"

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/networkInterfaces"
        },
        {
          field  = "Microsoft.Network/networkInterfaces/ipconfigurations[*].publicIpAddress.id"
          exists = true
        }
      ]
    }
    then = {
      effect = "allow"
    }
  })
}

# assigning policy
resource "azurerm_subscription_policy_assignment" "deny_nic_public_ip" {
  name                 = "deny-nic-public-ip-assignment"
  display_name         = "Deny NICs with Public IPs"
  policy_definition_id = azurerm_policy_definition.deny_nic_with_public_ip.id
  subscription_id      = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  location             = azurerm_resource_group.rg.location
}
*/