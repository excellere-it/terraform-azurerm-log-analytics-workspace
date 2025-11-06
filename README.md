# Log Analytics Workspace

Creates a logging workspace in Azure

- [Log Analytics Workspace](#log-analytics-workspace)
  - [Example](#example)
  - [Required Inputs](#required-inputs)
    - [ action\_group\_id](#-action_group_id)
    - [ azure\_monitor\_private\_link\_scope](#-azure_monitor_private_link_scope)
    - [ name](#-name)
    - [ resource\_group](#-resource_group)
  - [Optional Inputs](#optional-inputs)
    - [ expiration\_days](#-expiration_days)
    - [ optional\_tags](#-optional_tags)
    - [ solutions](#-solutions)
  - [Outputs](#outputs)
    - [ data\_collection\_rule\_id](#-data_collection_rule_id)
    - [ id](#-id)
    - [ location](#-location)
    - [ primary\_shared\_key](#-primary_shared_key)
    - [ workspace\_id](#-workspace_id)
  - [Resources](#resources)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
    - [ diagnostics](#-diagnostics)
    - [ name](#-name-1)
  - [Update Docs](#update-docs)
<!-- BEGIN_TF_DOCS -->


## Example

```hcl
locals {
  location       = "centralus"
  tags           = module.name.tags
  test_namespace = random_pet.instance_id.id
}

resource "random_pet" "instance_id" {}

resource "azurerm_resource_group" "example" {
  location = local.location
  name     = "rg-${local.test_namespace}"
  tags     = local.tags
}

resource "azurerm_monitor_private_link_scope" "example" {
  name                = "ampls-${local.test_namespace}"
  resource_group_name = azurerm_resource_group.example.name
  tags                = local.tags
}

resource "azurerm_monitor_action_group" "example" {
  name                = "CriticalAlertsAction"
  resource_group_name = azurerm_resource_group.example.name
  short_name          = "p0action"
  tags                = local.tags
}

module "example" {
  source = "../.."

  action_group_id = azurerm_monitor_action_group.example.id
  resource_group  = azurerm_resource_group.example

  azure_monitor_private_link_scope = {
    name                = azurerm_monitor_private_link_scope.example.name
    resource_group_name = azurerm_resource_group.example.name
  }

  name = {
    contact     = "nobody@infoex.dev"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-log-analytics-workspace"
    workload    = "apps"
  }

  solutions = {
    SQLAuditing = {
      publisher = "Microsoft"
      product   = "SQLAuditing"
    }
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id) | The ID of the action group to send alerts to. | `string` | n/a | yes |
| <a name="input_azure_monitor_private_link_scope"></a> [azure\_monitor\_private\_link\_scope](#input\_azure\_monitor\_private\_link\_scope) | The Azure Monitor Private Link Scope. | <pre>object({<br/>    name                = string<br/>    resource_group_name = string<br/>  })</pre> | n/a | yes |
| <a name="input_is_global"></a> [is\_global](#input\_is\_global) | Is the resource considered a global resource | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | The name tokens used to construct the resource name and tags. | <pre>object({<br/>    contact     = string<br/>    environment = string<br/>    instance    = optional(number)<br/>    repository  = string<br/>    workload    = string<br/>  })</pre> | n/a | yes |
| <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags) | A map of additional tags for the resource. | `map(string)` | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | The resource group to deploy resources into | <pre>object({<br/>    location = string<br/>    name     = string<br/>  })</pre> | n/a | yes |
| <a name="input_solutions"></a> [solutions](#input\_solutions) | The Log Analytics solutions to add to the workspace. | <pre>map(object({<br/>    publisher = string<br/>    product   = string<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_data_collection_rule_id"></a> [data\_collection\_rule\_id](#output\_data\_collection\_rule\_id) | The Data Collection Rule ID. |
| <a name="output_id"></a> [id](#output\_id) | The Log Analytics Workspace Resource ID. |
| <a name="output_location"></a> [location](#output\_location) | The location of the Log Analytics Workspace. |
| <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key) | The primary access key. |
| <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id) | The Log Analytics Workspace ID. |

## Resources

| Name | Type |
|------|------|
| [azurerm_log_analytics_solution.solution](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) | resource |
| [azurerm_log_analytics_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_monitor_data_collection_rule.dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) | resource |
| [azurerm_monitor_private_link_scoped_service.ampls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_private_link_scoped_service) | resource |
| [azurerm_monitor_scheduled_query_rules_alert_v2.alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) | resource |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.13 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.47 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics) | app.terraform.io/infoex/diagnostics/azurerm | 0.0.2 |
| <a name="module_name"></a> [name](#module\_name) | app.terraform.io/infoex/namer/terraform | 0.0.3 |
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```