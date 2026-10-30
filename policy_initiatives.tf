
# Policy 1: Deny resources missing required tags
resource "azurerm_policy_definition" "require_resource_tags" {
  name                = "poc-require-resource-tags"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Require environment and managed_by tags"
  description         = "Denies supported resources if required tags are missing."
  management_group_id = azurerm_management_group.organization.id

  metadata = jsonencode({
    category = "Tags"
  })

  policy_rule = jsonencode({
    if = {
      anyOf = [
        {
          field  = "tags['environment']"
          exists = "false"
        },
        {
          field  = "tags['managed_by']"
          exists = "false"
        }
      ]
    }
    then = {
      effect = "Deny"
    }
  })
}

# Policy 2: Deny public IPs outside approved regions
resource "azurerm_policy_definition" "deny_public_ip_regions" {
  name                = "poc-deny-public-ip-outside-approved-regions"
  policy_type         = "Custom"
  mode                = "All"
  display_name        = "Deny public IP addresses outside approved regions"
  description         = "Denies public IP creation outside approved regions."
  management_group_id = azurerm_management_group.organization.id

  metadata = jsonencode({
    category = "Network"
  })

  parameters = jsonencode({
    approvedRegions = {
      type = "Array"
      metadata = {
        displayName = "Approved regions"
        description = "Regions where public IP resources are allowed."
      }
    }
  })

  policy_rule = jsonencode({
    if = {
      allOf = [
        {
          field  = "type"
          equals = "Microsoft.Network/publicIPAddresses"
        },
        {
          field = "location"
          notIn = "[parameters('approvedRegions')]"
        }
      ]
    }
    then = {
      effect = "Deny"
    }
  })
}

# Policy 3: Existing Azure built-in storage private link policy
data "azurerm_policy_definition" "storage_private_link" {
  name = "6edd7eda-6dd8-40f7-810d-67160c639cd9"
}

# Combine all three policies into one initiative
resource "azurerm_policy_set_definition" "poc_governance" {
  name                = "poc-governance-initiative"
  policy_type         = "Custom"
  display_name        = "POC Governance Initiative"
  description         = "Tag enforcement, approved public IP regions, and storage private link auditing."
  management_group_id = azurerm_management_group.organization.id

  parameters = jsonencode({
    approvedPublicIpRegions = {
      type = "Array"
      metadata = {
        displayName = "Approved public IP regions"
        description = "Approved Azure regions for public IP resources."
      }
      defaultValue = var.approved_public_ip_regions
    }
  })

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.require_resource_tags.id
    reference_id         = "require-resource-tags"
  }

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.deny_public_ip_regions.id
    reference_id         = "deny-public-ip-regions"

    parameter_values = jsonencode({
      approvedRegions = {
        value = "[parameters('approvedPublicIpRegions')]"
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.storage_private_link.id
    reference_id         = "audit-storage-private-link"
  }
}

# Assign initiative to the organization management group
resource "azurerm_management_group_policy_assignment" "poc_governance" {
  name                 = "poc-governance"
  display_name         = "POC Governance Initiative"
  description          = "Applies the POC governance initiative to the organization hierarchy."
  management_group_id  = azurerm_management_group.organization.id
  policy_definition_id = azurerm_policy_set_definition.poc_governance.id

  parameters = jsonencode({
    approvedPublicIpRegions = {
      value = var.approved_public_ip_regions
    }
  })
}

output "poc_governance_initiative_id" {
  description = "ID of the governance initiative."
  value       = azurerm_policy_set_definition.poc_governance.id
}

output "poc_governance_assignment_id" {
  description = "ID of the management group policy assignment."
  value       = azurerm_management_group_policy_assignment.poc_governance.id
}
