output "id" {
  description = "The Log Analytics Workspace Resource ID."
  value       = azurerm_log_analytics_workspace.workspace.id
}

output "primary_shared_key" {
  description = "The primary access key."
  sensitive   = true
  value       = azurerm_log_analytics_workspace.workspace.primary_shared_key
}

output "workspace_id" {
  description = "The Log Analytics Workspace ID."
  value       = azurerm_log_analytics_workspace.workspace.workspace_id
}
