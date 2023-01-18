locals {
  alert = {
    APOT = {
      display_name                             = "Operational issues - ${azurerm_log_analytics_workspace.workspace.name}"
      evaluation_frequency                     = "P1D"
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
      operator                                 = "GreaterThan"
      query                                    = "_LogOperation | where Level == \"Warning\""
      resource_id_column                       = "_ResourceId"
      severity                                 = 3
      threshold                                = 0.0
      time_aggregation_method                  = "Count"
      window_duration                          = "P1D"
    }

    APIT = {
      display_name                             = "Data ingestion is exceeding the ingestion rate limit - ${azurerm_log_analytics_workspace.workspace.name}"
      evaluation_frequency                     = "PT5M"
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
      operator                                 = "GreaterThan"
      query                                    = "_LogOperation | where Category == \"Ingestion\" | where Operation has \"Ingestion rate\""
      resource_id_column                       = "_ResourceId"
      severity                                 = 2
      threshold                                = 0.0
      time_aggregation_method                  = "Count"
      window_duration                          = "PT5M"
    }

    APCT = {
      display_name                             = "Data ingestion has hit the daily cap - ${azurerm_log_analytics_workspace.workspace.name}"
      evaluation_frequency                     = "PT5M"
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
      operator                                 = "GreaterThan"
      query                                    = "_LogOperation | where Category == \"Ingestion\" | where Operation has \"Data collection\""
      resource_id_column                       = "_ResourceId"
      severity                                 = 2
      threshold                                = 0.0
      time_aggregation_method                  = "Count"
      window_duration                          = "PT5M"
    }
  }
}

module "name" {
  source  = "app.terraform.io/dellfoundation/namer/terraform"
  version = "0.0.5"

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
  internet_ingestion_enabled = false
  internet_query_enabled     = false
  location                   = var.resource_group.location
  name                       = "la-${module.name.resource_suffix}"
  resource_group_name        = var.resource_group.name
  retention_in_days          = 30
  sku                        = "PerGB2018"
  tags                       = module.name.tags
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

resource "azurerm_monitor_private_link_scoped_service" "ampls" {
  linked_resource_id  = azurerm_log_analytics_workspace.workspace.id
  name                = "amplss-${module.name.resource_suffix}"
  resource_group_name = var.resource_group.name
  scope_name          = var.azure_monitor_private_link_scope_name
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "alert" {
  for_each = local.alert

  display_name         = each.value.display_name
  evaluation_frequency = each.value.evaluation_frequency
  location             = var.resource_group.location
  name                 = "alert-la-${each.key}-${module.name.resource_suffix}"
  resource_group_name  = var.resource_group.name
  scopes               = [azurerm_log_analytics_workspace.workspace.id]
  tags                 = module.name.tags
  severity             = each.value.severity
  window_duration      = each.value.window_duration

  action {
    action_groups = [var.action_group_id]
  }

  criteria {
    operator                = each.value.operator
    query                   = each.value.query
    resource_id_column      = each.value.resource_id_column
    threshold               = each.value.threshold
    time_aggregation_method = each.value.time_aggregation_method

    failing_periods {
      minimum_failing_periods_to_trigger_alert = each.value.minimum_failing_periods_to_trigger_alert
      number_of_evaluation_periods             = each.value.number_of_evaluation_periods
    }
  }
}