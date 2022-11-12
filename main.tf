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

module "diagnostics" {
  source  = "app.terraform.io/dellfoundation/diagnostics/azurerm"
  version = "0.0.3"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  monitored_services = {
    la = {
      id = azurerm_log_analytics_workspace.workspace.id
    }
  }
}
