locals {
  location       = "centralus"
  tags           = module.name.tags
  test_namespace = random_pet.instance_id.id
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  for_each = toset(["logs", "ampls"])
  location = local.location
  name     = "rg-${each.key}-${local.test_namespace}"
  tags     = local.tags
}

resource "azurerm_monitor_private_link_scope" "example" {
  name                = "ampls-${local.test_namespace}"
  resource_group_name = azurerm_resource_group.example["ampls"].name
  tags                = local.tags
}

resource "azurerm_monitor_action_group" "example" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.example["logs"].name
  short_name          = "p0action"
  tags                = local.tags
}

module "example" {
  source = "../.."

  action_group_id = azurerm_monitor_action_group.example.id
  resource_group  = azurerm_resource_group.example["logs"]

  azure_monitor_private_link_scope = {
    name                = azurerm_monitor_private_link_scope.example.name
    resource_group_name = azurerm_resource_group.example["ampls"].name
  }

  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-log-analytics-workspace"
    workload    = "diffrg"
  }

  solutions = {
    SQLAuditing = {
      publisher = "Microsoft"
      product   = "SQLAuditing"
    }
  }
}
