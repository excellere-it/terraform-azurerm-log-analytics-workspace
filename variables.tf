variable "action_group_id" {
  description = "The ID of the action group to send alerts to."
  type        = string
}

variable "azure_monitor_private_link_scope" {
  description = "The Azure Monitor Private Link Scope name."
  type = object({
    name                = string
    resource_group_name = string
  })
}

variable "expiration_days" {
  default     = 365
  description = "Used to calculate the value of the EndDate tag by adding the specified number of days to the CreateDate tag."
  type        = number

  validation {
    condition     = 0 < var.expiration_days
    error_message = "Expiration days must be greater than zero."
  }
}

variable "name" {
  description = "The name tokens used to construct the resource name and tags."
  type = object({
    contact     = string
    environment = string
    instance    = optional(number)
    program     = optional(string)
    repository  = string
    workload    = string
  })
}

variable "optional_tags" {
  default     = {}
  description = "A map of additional tags for the resource."
  type        = map(string)
}

variable "resource_group" {
  description = "The resource group to deploy resources into"

  type = object({
    location = string
    name     = string
  })
}

variable "solutions" {
  description = "The Log Analytics solutions to add to the workspace."
  default     = {}

  type = map(object({
    publisher = string
    product   = string
  }))
}