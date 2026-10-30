# Enterprise Azure Governance — Management Group & Policy POC

## Project Overview

This project demonstrates an Infrastructure as Code (IaC) approach to building an Azure Management Group hierarchy and implementing foundational governance using Terraform.

The POC includes:
- Five custom Azure Management Groups.
- Custom Azure Policy definitions for required resource tags and approved public IP regions.
- A governance initiative combining custom policies and a built-in storage private-link policy.
- Management Group-level policy assignment.
- Terraform outputs for hierarchy verification.

## 1. Architecture — Management Group Hierarchy

```text
Tenant Root Group (built-in)
└── mg-poc-org
    ├── mg-poc-platform
    │   └── mg-poc-identity
    └── mg-poc-workloads
        └── mg-poc-dev
```

The hierarchy contains three custom levels beneath the built-in Tenant Root Group.

## 2. Azure Policy Governance

The Terraform configuration defines a custom governance initiative named `POC Governance Initiative`.

| Policy | Purpose | Effect |
|---|---|---|
| Require environment and managed_by tags | Deny supported resources missing required tags | Deny |
| Deny public IP outside approved regions | Restrict public IP creation to approved Azure regions | Deny |
| Storage accounts should use private link | Include the built-in storage private-link policy | Defined by the built-in policy |

**Approved public IP regions:** `centralindia`, `southindia`

The initiative is assigned at the `mg-poc-org` Management Group scope. Its effective scope includes descendant subscriptions and resources.

**Important validation note:** The POC subscription used during testing was not under `mg-poc-org`. Moving it was blocked by insufficient permissions. Therefore, policy deployment and assignment configuration should not be interpreted as proof of enforcement against that subscription's resources. End-to-end enforcement validation remains pending.

## 3. Prerequisites

- Terraform CLI 1.5+
- Azure CLI
- Azure subscription in the target Microsoft Entra tenant
- Permissions to create and manage Management Groups
- Required Azure Policy definition and assignment permissions at the target scope
- Appropriate tenant-level permissions if hierarchy protection is enabled

## 4. Sign in to Azure

```bash
az login
az account list --output table
az account set --subscription "<YOUR-SUBSCRIPTION-ID>"
az account show --query "{name:name, subscriptionId:id, tenantId:tenantId}" --output table
```

Confirm that you are signed in to the intended tenant before deployment.

## 5. Configure Terraform variables

Copy the example variables file.

**Linux/macOS**

```bash
cp terraform.tfvars.example terraform.tfvars
```

**PowerShell**

```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Update `terraform.tfvars` with your actual subscription ID and required configuration values.

Do not commit `terraform.tfvars` or any credentials to GitHub.

## 6. Initialize and validate

```bash
terraform init
terraform fmt -recursive
terraform validate
```

## 7. Preview and deploy

```bash
terraform plan -out main.tfplan
terraform apply main.tfplan
```

Review the Terraform plan before applying.

Management Groups are tenant-level governance objects. Confirm the target tenant and deployment permissions before proceeding.

## 8. Verify deployment

List Management Groups:

```bash
az account management-group list --output table
```

Display Terraform hierarchy outputs:

```bash
terraform output hierarchy_summary
terraform output management_group_hierarchy
```

For policy verification, use Azure Policy in the portal or Azure CLI to inspect the initiative, assignment scope, compliance states, and policy evaluation results.

Policy compliance results may take time to reflect after deployment.

## 9. Automation POC

A separate Azure Automation Runbook named `PolicyComplianceScan` was configured and published during the POC.

The runbook:
- Authenticates using the Automation Account managed identity.
- Sets the target subscription context.
- Retrieves Azure Policy state records.
- Generates a JSON compliance summary.

**Recorded execution result:**
- Total policy-state records: 51
- Compliant records: 14
- Non-compliant records: 37
- Job status: Completed

These figures represent policy-state records, not necessarily unique resources or only the custom initiative's results.

Daily scheduling and additional integrations remain pending.

## 10. Repository File Structure

| File | Description |
|---|---|
| `main.tf` | Management Group hierarchy |
| `policy_initiatives.tf` | Custom policy definitions, governance initiative and assignment |
| `variables.tf` | Terraform input variables |
| `outputs.tf` | Management Group IDs and hierarchy summary |
| `versions.tf` | Terraform and AzureRM provider configuration |
| `terraform.tfvars.example` | Example configuration values |
| `.terraform.lock.hcl` | Provider dependency lock file |
| `.gitignore` | Excludes local state, plans and sensitive configuration |

## 11. Known Limitations and Pending Work

The following enterprise governance components are part of the broader assignment but are not yet fully implemented or validated:

- Custom RBAC role definitions and assignments.
- Privileged Identity Management (PIM) activation and approval workflow.
- B2B guest access governance, Conditional Access and Access Reviews.
- Microsoft Graph automation for permanent privileged-role assignment detection.
- JSON report upload to Azure Storage and Teams webhook notifications.
- Defender for Cloud regulatory compliance integration with Log Analytics.
- Daily scheduling of the compliance Runbook.
- End-to-end policy enforcement validation against a subscription under the assigned Management Group.

These items are intentionally identified as pending rather than represented as completed.

## 12. Cleanup

Only remove resources if you are authorized and intend to delete the POC.

```bash
terraform plan -destroy
terraform destroy
```

Terraform can delete custom Management Groups only when their child resources, subscriptions and dependencies permit it.

Never attempt to delete the built-in Tenant Root Group.

## 13. Troubleshooting

**AuthorizationFailed / managementGroups/write**

Your identity may lack Management Group permissions or tenant hierarchy protection may be enabled. Ask the tenant administrator to grant the required permissions at the appropriate scope.

**Wrong tenant**

```bash
az account show
```

Verify the tenant ID before applying Terraform.

**Provider subscription ID error**

Verify the `subscription_id` value in your local `terraform.tfvars`.

**Management Group already exists**

Choose a unique name prefix or import and manage the existing Management Group rather than attempting to recreate it.

**Policy assignment does not affect a subscription**

Confirm that the subscription is actually under the Management Group where the policy initiative is assigned.

## 14. Project Repository

GitHub: https://github.com/Manoj437-star/azure-management-group-terraform

---

**Project:** Enterprise Azure Governance POC  
**Technology:** Microsoft Azure, Terraform, Azure Policy, Azure Automation, PowerShell  
**Purpose:** Azure governance implementation and L2 DevOps practical demonstration
