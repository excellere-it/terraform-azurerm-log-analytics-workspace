locals {
  resource_suffix = join("-", compact([var.name.workload, var.name.environment, var.resource_group.location, var.name.program, var.name.instance]))
  tags            = merge(local.default_tags, var.required_tags, var.optional_tags)

  default_tags = {
    CreateDate = formatdate("YYYY-MM-DD", time_static.create_date.rfc3339)
    EndDate    = formatdate("YYYY-MM-DD", time_offset.end_date.rfc3339)
    Source     = "IAC"
  }
}

resource "time_static" "create_date" {}

resource "time_offset" "end_date" {
  base_rfc3339 = time_static.create_date.id
  offset_years = var.expiration_years
}

resource "azurerm_log_analytics_workspace" "workspace" {
  location            = var.resource_group.location
  name                = "la-${local.resource_suffix}"
  resource_group_name = var.resource_group.name
  retention_in_days   = 30
  sku                 = "PerGB2018"
  tags                = local.tags
}

resource "azurerm_monitor_diagnostic_setting" "audits" {
  name                       = "diag-la"
  target_resource_id         = azurerm_log_analytics_workspace.workspace.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  log {
    category = "Audit"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      enabled = false
    }
  }
}