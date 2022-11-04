locals {
  test_namespace = random_pet.instance_id.id

  tags = {
    Contact    = "nobody@dell.org"
    Program    = "DYL"
    Repository = "terraform-azurerm-log-analytics-workspace"
  }
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = "centralus"
  name     = "rg-${local.test_namespace}"
  tags     = local.tags
}

module "example" {
  source = "../.."

  resource_group = azurerm_resource_group.example
  required_tags  = local.tags

  # The following tokens are optional: instance, program
  name = {
    workload    = "apps"
    environment = "sbx"
    program     = "dyl"
  }
}
