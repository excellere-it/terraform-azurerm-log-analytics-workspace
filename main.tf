module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.2"

  contact         = var.name.contact
  environment     = var.name.environment
  expiration_days = var.expiration_days
  instance        = var.name.instance
  location        = var.resource_group.location
  optional_tags   = var.optional_tags
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
  tags                = module.name.tags
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

resource "azurerm_log_analytics_solution" "solution" {
  for_each = var.solutions

  location              = var.resource_group.location
  resource_group_name   = var.resource_group.name
  solution_name         = each.key
  tags                  = module.name.tags
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id

  plan {
    publisher = each.value.publisher
    product   = each.value.product
  }
}
