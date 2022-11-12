locals {
  tags = merge(module.name.tags, var.optional_tags)
}

module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact         = var.name.contact
  environment     = var.name.environment
  expiration_days = var.expiration_days
  instance        = var.name.instance
  location        = var.resource_group.location
  program         = var.name.program
  repository      = var.name.repository
  workload        = var.name.workload
}

resource "azurerm_log_analytics_workspace" "workspace" {
  location            = var.resource_group.location
  name                = "la-${module.name.resource_suffix}"
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