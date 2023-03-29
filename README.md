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
    contact     = "nobody@dell.org"
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

## Required Inputs

The following input variables are required:

### <a name="input_action_group_id"></a> [action\_group\_id](#input\_action\_group\_id)

Description: The ID of the action group to send alerts to.

Type: `string`

### <a name="input_azure_monitor_private_link_scope"></a> [azure\_monitor\_private\_link\_scope](#input\_azure\_monitor\_private\_link\_scope)

Description: The Azure Monitor Private Link Scope.

Type:

```hcl
object({
    name                = string
    resource_group_name = string
  })
```

### <a name="input_name"></a> [name](#input\_name)

Description: The name tokens used to construct the resource name and tags.

Type:

```hcl
object({
    contact     = string
    environment = string
    instance    = optional(number)
    program     = optional(string)
    repository  = string
    workload    = string
  })
```

### <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group)

Description: The resource group to deploy resources into

Type:

```hcl
object({
    location = string
    name     = string
  })
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_expiration_days"></a> [expiration\_days](#input\_expiration\_days)

Description: Used to calculate the value of the EndDate tag by adding the specified number of days to the CreateDate tag.

Type: `number`

Default: `365`

### <a name="input_optional_tags"></a> [optional\_tags](#input\_optional\_tags)

Description: A map of additional tags for the resource.

Type: `map(string)`

Default: `{}`

### <a name="input_solutions"></a> [solutions](#input\_solutions)

Description: The Log Analytics solutions to add to the workspace.

Type:

```hcl
map(object({
    publisher = string
    product   = string
  }))
```

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_data_collection_rule_id"></a> [data\_collection\_rule\_id](#output\_data\_collection\_rule\_id)

Description: The Data Collection Rule ID.

### <a name="output_id"></a> [id](#output\_id)

Description: The Log Analytics Workspace Resource ID.

### <a name="output_location"></a> [location](#output\_location)

Description: The location of the Log Analytics Workspace.

### <a name="output_primary_shared_key"></a> [primary\_shared\_key](#output\_primary\_shared\_key)

Description: The primary access key.

### <a name="output_workspace_id"></a> [workspace\_id](#output\_workspace\_id)

Description: The Log Analytics Workspace ID.

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_solution.solution](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution) (resource)
- [azurerm_log_analytics_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_monitor_data_collection_rule.dcr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_data_collection_rule) (resource)
- [azurerm_monitor_private_link_scoped_service.ampls](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_private_link_scoped_service) (resource)
- [azurerm_monitor_scheduled_query_rules_alert_v2.alert](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_scheduled_query_rules_alert_v2) (resource)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.41)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.41)

## Modules

The following Modules are called:

### <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics)

Source: app.terraform.io/dellfoundation/diagnostics/azurerm

Version: 0.0.10

### <a name="module_name"></a> [name](#module\_name)

Source: app.terraform.io/dellfoundation/namer/terraform

Version: 0.0.7
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```