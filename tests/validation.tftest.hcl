# Input validation tests for Log Analytics Workspace module

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

run "test_valid_configuration" {
  command = plan

  variables {
    action_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/actionGroups/test-ag"

    resource_group = {
      location = "centralus"
      name     = "rg-test"
    }

    azure_monitor_private_link_scope = {
      name                = "ampls-test"
      resource_group_name = "rg-test"
    }

    name = {
      contact     = "test@example.com"
      environment = "sbx"
      repository  = "terraform-azurerm-log-analytics-workspace"
      workload    = "test"
    }
  }

  assert {
    condition     = azurerm_log_analytics_workspace.workspace.name != null
    error_message = "Valid configuration should create workspace"
  }
}

# Tests for expiration_days removed - variable no longer exists in module

run "test_optional_tags" {
  command = plan

  variables {
    action_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/actionGroups/test-ag"

    resource_group = {
      location = "centralus"
      name     = "rg-test"
    }

    azure_monitor_private_link_scope = {
      name                = "ampls-test"
      resource_group_name = "rg-test"
    }

    name = {
      contact     = "test@example.com"
      environment = "sbx"
      repository  = "terraform-azurerm-log-analytics-workspace"
      workload    = "test"
    }

    optional_tags = {
      CustomTag  = "CustomValue"
      Department = "IT"
    }
  }

  assert {
    condition     = var.optional_tags["CustomTag"] == "CustomValue"
    error_message = "Should accept optional tags"
  }
}

run "test_empty_solutions" {
  command = plan

  variables {
    action_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/actionGroups/test-ag"

    resource_group = {
      location = "centralus"
      name     = "rg-test"
    }

    azure_monitor_private_link_scope = {
      name                = "ampls-test"
      resource_group_name = "rg-test"
    }

    name = {
      contact     = "test@example.com"
      environment = "sbx"
      repository  = "terraform-azurerm-log-analytics-workspace"
      workload    = "test"
    }

    solutions = {}
  }

  assert {
    condition     = length(keys(azurerm_log_analytics_solution.solution)) == 0
    error_message = "Should handle empty solutions map"
  }
}

run "test_name_with_optional_instance" {
  command = plan

  variables {
    action_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/actionGroups/test-ag"

    resource_group = {
      location = "centralus"
      name     = "rg-test"
    }

    azure_monitor_private_link_scope = {
      name                = "ampls-test"
      resource_group_name = "rg-test"
    }

    name = {
      contact     = "test@example.com"
      environment = "sbx"
      instance    = 2
      repository  = "terraform-azurerm-log-analytics-workspace"
      workload    = "test"
    }
  }

  assert {
    condition     = var.name.instance == 2
    error_message = "Should accept optional instance number"
  }
}

# Test removed: 'program' is not supported by terraform-namer module

run "test_different_locations" {
  command = plan

  variables {
    action_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Insights/actionGroups/test-ag"

    resource_group = {
      location = "eastus2"
      name     = "rg-test"
    }

    azure_monitor_private_link_scope = {
      name                = "ampls-test"
      resource_group_name = "rg-test"
    }

    name = {
      contact     = "test@example.com"
      environment = "prd"
      repository  = "terraform-azurerm-log-analytics-workspace"
      workload    = "prod"
    }
  }

  assert {
    condition     = azurerm_log_analytics_workspace.workspace.location == "eastus2"
    error_message = "Should support different Azure locations"
  }
}
