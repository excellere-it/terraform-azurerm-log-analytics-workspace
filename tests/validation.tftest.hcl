# Input validation tests for Log Analytics Workspace module

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

run "test_expiration_days_validation_positive" {
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

    expiration_days = 365
  }

  assert {
    condition     = var.expiration_days == 365
    error_message = "Should accept valid expiration_days value"
  }
}

run "test_expiration_days_validation_negative" {
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

    expiration_days = 0
  }

  expect_failures = [
    var.expiration_days,
  ]
}

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

run "test_name_with_optional_program" {
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
      program     = "myprogram"
      repository  = "terraform-azurerm-log-analytics-workspace"
      workload    = "test"
    }
  }

  assert {
    condition     = var.name.program == "myprogram"
    error_message = "Should accept optional program name"
  }
}

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
