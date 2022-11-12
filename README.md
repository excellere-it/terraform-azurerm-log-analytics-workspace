# Log Analytics Workspace

Creates a logging workspace in Azure

- [Log Analytics Workspace](#log-analytics-workspace)
  - [Example](#example)
  - [Required Inputs](#required-inputs)
    - [<a name="input_name"></a> name](#-name)
    - [<a name="input_required_tags"></a> required\_tags](#-required_tags)
    - [<a name="input_resource_group"></a> resource\_group](#-resource_group)
  - [Optional Inputs](#optional-inputs)
    - [<a name="input_expiration_years"></a> expiration\_years](#-expiration_years)
    - [<a name="input_optional_tags"></a> optional\_tags](#-optional_tags)
  - [Outputs](#outputs)
    - [<a name="output_id"></a> id](#-id)
  - [Resources](#resources)
  - [Requirements](#requirements)
  - [Providers](#providers)
  - [Modules](#modules)
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

module "example" {
  source = "../.."

  resource_group = azurerm_resource_group.example

  # The following tokens are optional: instance, program
  name = {
    contact     = "nobody@dell.org"
    environment = "sbx"
    program     = "dyl"
    repository  = "terraform-azurerm-log-analytics-workspace"
    workload    = "apps"
  }
}
```

## Required Inputs

The following input variables are required:

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

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The Log Analytics Workspace ID.

## Resources

The following resources are used by this module:

- [azurerm_log_analytics_workspace.workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_monitor_diagnostic_setting.audits](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) (resource)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.3.3)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.31)

- <a name="requirement_time"></a> [time](#requirement\_time) (~> 0.9)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 3.31)

## Modules

The following Modules are called:

### <a name="module_name"></a> [name](#module\_name)

Source: app.terraform.io/dellfoundation/namer/terraform

Version: 0.0.2
<!-- END_TF_DOCS -->

## Update Docs

Run this command:

```
terraform-docs markdown document --output-file README.md --output-mode inject .
```