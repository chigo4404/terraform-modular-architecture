output "policy_assignment_ids" {
  value = [
    #azurerm_subscription_policy_assignment.audit_tags.id,
    azurerm_subscription_policy_assignment.block_public_ips.id
  ]
}
