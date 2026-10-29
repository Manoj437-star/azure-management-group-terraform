# Level 1 (custom): this group is created beneath Azure's built-in Tenant Root Group.
# If parent_management_group_id is omitted, Azure places it under the tenant root group.
resource "azurerm_management_group" "organization" {
  name         = "${var.name_prefix}-org"
  display_name = var.organization_display_name
}

# Level 2: platform branch.
resource "azurerm_management_group" "platform" {
  name                       = "${var.name_prefix}-platform"
  display_name               = var.platform_display_name
  parent_management_group_id = azurerm_management_group.organization.id
}

# Level 2: workloads branch.
resource "azurerm_management_group" "workloads" {
  name                       = "${var.name_prefix}-workloads"
  display_name               = var.workloads_display_name
  parent_management_group_id = azurerm_management_group.organization.id
}

# Level 3: child of Platform.
resource "azurerm_management_group" "identity" {
  name                       = "${var.name_prefix}-identity"
  display_name               = var.identity_display_name
  parent_management_group_id = azurerm_management_group.platform.id
}

# Level 3: child of Workloads.
resource "azurerm_management_group" "development" {
  name                       = "${var.name_prefix}-dev"
  display_name               = var.dev_display_name
  parent_management_group_id = azurerm_management_group.workloads.id
}
