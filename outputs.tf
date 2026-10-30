output "management_group_hierarchy" {
  description = "Management group IDs created by this configuration."
  value = {
    organization = azurerm_management_group.organization.id
    platform     = azurerm_management_group.platform.id
    workloads    = azurerm_management_group.workloads.id
    identity     = azurerm_management_group.identity.id
    development  = azurerm_management_group.development.id
  }
}

output "hierarchy_summary" {
  description = "Human-readable hierarchy."
  value       = <<-EOT
  Tenant Root Group (built-in)
  └── ${azurerm_management_group.organization.display_name}
      ├── ${azurerm_management_group.platform.display_name}
      │   └── ${azurerm_management_group.identity.display_name}
      └── ${azurerm_management_group.workloads.display_name}
          └── ${azurerm_management_group.development.display_name}
  EOT
}
