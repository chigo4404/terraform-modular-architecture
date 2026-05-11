


resource "azurerm_portal_dashboard" "healthcheck" {

  name                = "dashboard-${var.client_name}"
  resource_group_name = var.rg_name
  location            = var.location

  tags = var.tags

  dashboard_properties = jsonencode({

    lenses = {
      "0" = {
        order = 0
        parts = {

          # =====================================================
          # EXECUTIVE SUMMARY
          # =====================================================

          "0" = {
            position = {
              x = 0
              y = 0
              colSpan = 4
              rowSpan = 2
            }

            metadata = {
              type = "Extension/HubsExtension/PartType/MarkdownPart"

              settings = {
                content = {
                  settings = {
                    title = "Cloud Operations Dashboard"

                    content = <<MARKDOWN
# ${var.client_name}

Environment: **${var.environment}**

This dashboard provides:

- Infrastructure health
- Cost governance
- SQL monitoring
- VM monitoring
- Alert visibility
MARKDOWN

                  }
                }
              }
            }
          }

          # =====================================================
          # VM CPU
          # =====================================================

          "1" = {
            position = {
              x = 4
              y = 0
              colSpan = 4
              rowSpan = 3
            }

            metadata = {
              type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"

              inputs = [
                {
                  name = "resourceId"

                  value = var.vm_ids[0]
                },

                {
                  name = "metrics"

                  value = [
                    {
                      name = "Percentage CPU"
                      aggregationType = "Average"
                    }
                  ]
                }
              ]
            }
          }

          # =====================================================
          # SQL AVAILABILITY
          # =====================================================

          "2" = {
            position = {
              x = 8
              y = 0
              colSpan = 4
              rowSpan = 3
            }

            metadata = {
              type = "Extension/Microsoft_Azure_Monitoring/PartType/MetricsChartPart"

              inputs = [
                {
                  name = "resourceId"

                  value = var.sql_database_id
                },

                {
                  name = "metrics"

                  value = [
                    {
                      name = "availability"
                      aggregationType = "Average"
                    }
                  ]
                }
              ]
            }
          }

          # =====================================================
          # MEMORY QUERY
          # =====================================================

          "3" = {
            position = {
              x = 0
              y = 3
              colSpan = 6
              rowSpan = 4
            }

            metadata = {
              type = "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart"

              inputs = [
                {
                  name = "workspaceId"

                  value = var.log_analytics_id
                },

                {
                  name = "query"

                  value = <<KQL
Perf
| where CounterName == "% Committed Bytes In Use"
| summarize AvgMemory = avg(CounterValue) by bin(TimeGenerated, 5m)
KQL

                },

                {
                  name = "chartType"
                  value = "Line"
                }
              ]
            }
          }

          # =====================================================
          # DISK QUERY
          # =====================================================

          "4" = {
            position = {
              x = 6
              y = 3
              colSpan = 6
              rowSpan = 4
            }

            metadata = {
              type = "Extension/Microsoft_OperationsManagementSuite_Workspace/PartType/LogsDashboardPart"

              inputs = [
                {
                  name = "workspaceId"

                  value = var.log_analytics_id
                },

                {
                  name = "query"

                  value = <<KQL
Perf
| where CounterName == "% Free Space"
| summarize AvgDisk = avg(CounterValue) by bin(TimeGenerated, 5m)
KQL

                },

                {
                  name = "chartType"
                  value = "Line"
                }
              ]
            }
          }

        }
      }
    }

    metadata = {
      model = {
        timeRange = {
          value = {
            relative = {
              duration = 24
              timeUnit = 1
            }
          }
        }
      }
    }

  })
}



variable "tags" {
  type        = map(string)
  description = "Tags required by the Governance Policy"
}



# 1. Action Group: Who gets the email?
resource "azurerm_monitor_action_group" "dev_ops" {
  name                = "ag-billingadmin-${var.client_name}"
  resource_group_name = var.rg_name
  short_name          = "BillingAdmin"
  
  tags = var.tags

  email_receiver {
    name                    = "Admin"
    email_address           = var.admin_email # Add this to your variables
    use_common_alert_schema = true
  }
}

# 2. CPU Alert (Platform Metric)
resource "azurerm_monitor_metric_alert" "cpu_alert" {
  name                = "alert-cpu-high"
  resource_group_name = var.rg_name
  scopes = var.vm_ids# Use variable for VM ID from Compute Module output
  #scopes              = [azurerm_linux_virtual_machine.vm.id] # Scope to the Linux VMs in the Compute Module
  #scopes              = [azurerm_virtual_machine.vm.id] # trying to scope to any VM in the Compute Module
  description         = "Triggers when average CPU > 80% for 5 minutes."
  severity            = 2
  
  target_resource_type     = "Microsoft.Compute/virtualMachines"
  target_resource_location = var.location
  
  criteria {
    metric_namespace = "Microsoft.Compute/virtualMachines"
    metric_name      = "Percentage CPU"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.dev_ops.id
  }
  tags = var.tags
}

# 3. Consumption Budget (Cost Control)
resource "azurerm_consumption_budget_resource_group" "dev_budget" {
  name              = "budget-${var.client_name}"
  resource_group_id = var.rg_id
  amount            = var.budget_amount
  time_grain        = "Monthly"

  time_period {
    start_date = formatdate("YYYY-MM-01'T'00:00:00Z", timestamp()) # Current month
    end_date   = "2026-12-31T00:00:00Z"
  }

  notification {
    enabled        = true
    threshold      = 80.0 # Notify at 80% of budget
    operator       = "EqualTo"
    contact_emails = [var.admin_email]
  }
}
# SQL Availability Alert. This will email you if the database becomes unreachable

resource "azurerm_monitor_metric_alert" "sql_health" {
  name                = "alert-sql-availability"
  resource_group_name = var.rg_name
  #scopes              = [azurerm_mssql_database.db.id]
    scopes              = [var.sql_database_id] # Use variable for SQL Database ID
  description         = "Triggers if the SQL Database availability drops below 99%."
  severity            = 1 # Critical

   tags = var.tags
  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "availability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }
  

  action {
    action_group_id = azurerm_monitor_action_group.dev_ops.id
  }
}

