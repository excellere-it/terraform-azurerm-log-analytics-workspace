# =============================================================================
# Module: Azure Log Analytics Workspace
# =============================================================================
#
# Purpose:
#   This Terraform module creates and manages an Azure Log Analytics Workspace
#   with integrated monitoring, alerting, and data collection capabilities.
#
# Features:
#   - **Log Analytics Workspace**: Centralized log collection and analysis
#   - **VM Insights Integration**: Data collection rules for virtual machine monitoring
#   - **Solutions Management**: Deploy workspace solutions (e.g., SecurityCenter, Updates)
#   - **Alert Rules**: Pre-configured alerts for operational issues and ingestion limits
#   - **Data Collection Rules**: VM Insights performance and dependency tracking
#   - **Standardized Naming**: Uses terraform-terraform-namer for consistent naming
#   - **Tagging**: Applies consistent tags across all resources
#
# Resources Created:
#   - **Log Analytics Workspace** (`azurerm_log_analytics_workspace.workspace`)
#     - Name format: `la-{resource_suffix}`
#     - SKU: PerGB2018 (pay-as-you-go)
#     - Retention: 90 days
#     - Internet ingestion and query: enabled
#
#   - **Data Collection Rule** (`azurerm_monitor_data_collection_rule.dcr`)
#     - Name format: `MSVMI-{workspace-name}`
#     - Streams: InsightsMetrics, ServiceMap
#     - Performance counters: VM Insights detailed metrics
#     - Dependency Agent integration
#
#   - **Scheduled Query Rules** (`azurerm_monitor_scheduled_query_rules_alert_v2.alert`)
#     - APOT: Operational issues warning (severity 3, daily check)
#     - APIT: Ingestion rate limit exceeded (severity 2, 5-minute check)
#     - APCT: Daily cap hit (severity 2, 5-minute check)
#
#   - **Workspace Solutions** (`azurerm_log_analytics_solution.solution`)
#     - Configurable solutions (SecurityCenter, Updates, ChangeTracking, etc.)
#     - Auto-deploys based on var.solutions map
#
# Use Cases:
#   - **Centralized Logging**: Collect logs from Azure resources, VMs, containers
#   - **VM Monitoring**: Enable VM Insights for performance and dependency tracking
#   - **Security Monitoring**: Deploy SecurityCenter solution for threat detection
#   - **Compliance**: Retain logs for regulatory compliance (configurable retention)
#   - **Cost Management**: Monitor ingestion rates and daily caps to control costs
#
# Azure Log Analytics Documentation:
#   https://docs.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview
#
# Example:
#   ```hcl
#   module "log_analytics" {
#     source = "path/to/module"
#
#     action_group_id = azurerm_monitor_action_group.example.id
#     resource_group = {
#       name     = azurerm_resource_group.example.name
#       location = azurerm_resource_group.example.location
#     }
#
#     solutions = {
#       "SecurityCenterFree" = {
#         publisher = "Microsoft"
#         product   = "OMSGallery/SecurityCenterFree"
#       }
#     }
#
#     name = {
#       contact     = "devops@example.com"
#       environment = "prod"
#       repository  = "terraform-infrastructure"
#       workload    = "monitoring"
#     }
#   }
#   ```
#
# Notes:
#   - Workspace SKU is fixed to PerGB2018 (pay-per-GB ingested)
#   - Retention is fixed to 90 days (modify in main.tf if needed)
#   - Internet ingestion/query enabled by default (set to false for private-only)
#   - VM Insights DCR is automatically created for each workspace
#   - Alert rules query the _LogOperation table (workspace operational logs)
#   - Solutions must be specified in the solutions variable (map of objects)
#
# Dependencies:
#   - terraform-terraform-namer (required for naming and tagging)
#   - azurerm_monitor_action_group (required for alert notifications)
#
# Performance Considerations:
#   - Ingestion rate limits: Varies by workspace (monitored by APIT alert)
#   - Daily cap: Optional cost control (monitored by APCT alert)
#   - Query performance: Depends on data volume and query complexity
#   - Data retention: Longer retention increases storage costs
#
# Security:
#   - RBAC recommended for access control
#   - Network isolation available via Private Link (not configured in this module)
#   - Customer-managed keys supported for encryption at rest (not configured in this module)
#
# =============================================================================

# Section: Alert Definitions
# =============================================================================

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

# Section: Workspace Solutions
# =============================================================================

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

# Section: Log Analytics Workspace
# =============================================================================

resource "azurerm_log_analytics_workspace" "workspace" {
  internet_ingestion_enabled = true
  internet_query_enabled     = true
  location                   = var.resource_group.location
  name                       = "la-${module.name.resource_suffix}"
  resource_group_name        = var.resource_group.name
  retention_in_days          = 365
  sku                        = "PerGB2018"
  tags                       = module.name.tags
}

# Section: Data Collection Rule (VM Insights)
# =============================================================================

resource "azurerm_monitor_data_collection_rule" "dcr" {
  description         = "Data collection rule for VM Insights."
  location            = var.resource_group.location
  name                = "MSVMI-${azurerm_log_analytics_workspace.workspace.name}"
  resource_group_name = var.resource_group.name
  tags                = module.name.tags

  data_flow {
    destinations = ["VMInsightsPerf-Logs-Dest"]
    streams      = ["Microsoft-InsightsMetrics"]
  }

  data_flow {
    destinations = ["VMInsightsPerf-Logs-Dest"]
    streams      = ["Microsoft-ServiceMap"]
  }

  data_sources {
    extension {
      extension_name = "DependencyAgent"
      name           = "DependencyAgentDataSource"
      streams        = ["Microsoft-ServiceMap"]
    }
    performance_counter {
      counter_specifiers            = ["\\VmInsights\\DetailedMetrics"]
      name                          = "VMInsightsPerfCounters"
      sampling_frequency_in_seconds = 60
      streams                       = ["Microsoft-InsightsMetrics"]
    }
  }

  destinations {
    log_analytics {
      name                  = "VMInsightsPerf-Logs-Dest"
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
    }
  }
}

# Section: Private Link Scoped Service
# =============================================================================

resource "azurerm_monitor_private_link_scoped_service" "ampls" {
  linked_resource_id  = azurerm_log_analytics_workspace.workspace.id
  name                = "amplss-${module.name.resource_suffix}"
  resource_group_name = var.azure_monitor_private_link_scope.resource_group_name
  scope_name          = var.azure_monitor_private_link_scope.name
}

# Section: Scheduled Query Alert Rules
# =============================================================================

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

# Section: Diagnostic Settings
# =============================================================================

module "diagnostics" {
  source  = "app.terraform.io/infoex/diagnostics/azurerm"
  version = "0.0.3"

  log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

  monitored_services = {
    la = {
      id = azurerm_log_analytics_workspace.workspace.id
    }
  }
}

# Section: Naming and Tagging
# =============================================================================

module "name" {
  source  = "app.terraform.io/infoex/namer/terraform"
  version = "0.0.2"

  contact       = var.name.contact
  environment   = var.name.environment
  instance      = var.name.instance
  location      = var.is_global ? "global" : var.resource_group.location
  optional_tags = var.optional_tags
  repository    = var.name.repository
  workload      = var.name.workload
}
