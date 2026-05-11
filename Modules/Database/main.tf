resource "azurerm_mssql_server" "sql" {
  name                         = "sql-${var.db_name}"
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = var.admin_user
  administrator_login_password = var.admin_password
  lifecycle {
  prevent_destroy = true
}
}

resource "azurerm_mssql_database" "db" {
  name           = var.db_name
  server_id      = azurerm_mssql_server.sql.id
  sku_name       = "Basic"
   depends_on     = [azurerm_mssql_server.sql]
  lifecycle {
  prevent_destroy = true
}
}

# Diagnostic Setting to link DB to Log Analytics for monitoring
resource "azurerm_monitor_diagnostic_setting" "sql_diag" {
  name                       = "diag-${var.db_name}"
  target_resource_id         = azurerm_mssql_database.db.id
  log_analytics_workspace_id = var.log_analytics_id

  # Monitoring Security (Standard for Architects)
  enabled_log {
    category = "SQLSecurityAuditEvents"
  }

  # Monitoring Performance
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
