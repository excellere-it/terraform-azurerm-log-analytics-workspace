# Basic functionality tests for Log Analytics Workspace module

run "test_basic_workspace" {
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

  # Verify workspace is created
  assert {
    condition     = azurerm_log_analytics_workspace.workspace.name != null
    error_message = "Log Analytics Workspace name should not be null"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.workspace.location == "centralus"
    error_message = "Log Analytics Workspace location should be centralus"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.workspace.sku == "PerGB2018"
    error_message = "Log Analytics Workspace SKU should be PerGB2018"
  }

  assert {
    condition     = azurerm_log_analytics_workspace.workspace.retention_in_days == 90
    error_message = "Log Analytics Workspace retention should be 90 days"
  }
}

run "test_outputs_generated" {
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

  # Verify all outputs are generated
  assert {
    condition     = output.id != null
    error_message = "Output 'id' should not be null"
  }

  assert {
    condition     = output.workspace_id != null
    error_message = "Output 'workspace_id' should not be null"
  }

  assert {
    condition     = output.location != null
    error_message = "Output 'location' should not be null"
  }

  assert {
    condition     = output.data_collection_rule_id != null
    error_message = "Output 'data_collection_rule_id' should not be null"
  }
}

run "test_data_collection_rule" {
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

  # Verify data collection rule is created
  assert {
    condition     = azurerm_monitor_data_collection_rule.dcr.name != null
    error_message = "Data Collection Rule name should not be null"
  }

  assert {
    condition     = azurerm_monitor_data_collection_rule.dcr.location == "centralus"
    error_message = "Data Collection Rule location should match workspace location"
  }

  assert {
    condition     = length(azurerm_monitor_data_collection_rule.dcr.data_flow) == 2
    error_message = "Data Collection Rule should have 2 data flows"
  }
}

run "test_alerts_created" {
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

  # Verify alert rules are created (3 alerts: APOT, APIT, APCT)
  assert {
    condition     = length(keys(azurerm_monitor_scheduled_query_rules_alert_v2.alert)) == 3
    error_message = "Should create 3 alert rules"
  }
}

run "test_with_solutions" {
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

    solutions = {
      SQLAuditing = {
        publisher = "Microsoft"
        product   = "SQLAuditing"
      }
      Security = {
        publisher = "Microsoft"
        product   = "OMSGallery/Security"
      }
    }
  }

  # Verify solutions are created
  assert {
    condition     = length(keys(azurerm_log_analytics_solution.solution)) == 2
    error_message = "Should create 2 Log Analytics solutions"
  }
}

run "test_private_link_integration" {
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

  # Verify private link scoped service is created
  assert {
    condition     = azurerm_monitor_private_link_scoped_service.ampls.name != null
    error_message = "Private Link Scoped Service name should not be null"
  }

  assert {
    condition     = azurerm_monitor_private_link_scoped_service.ampls.scope_name == "ampls-test"
    error_message = "Private Link Scoped Service should reference correct AMPLS"
  }
}
