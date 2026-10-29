# Azure Management Group Hierarchy — Terraform POC

This project creates five custom Azure Management Groups with three custom levels beneath the built-in Tenant Root Group.

```text
Tenant Root Group (built-in)
└── mg-poc-org                       # Custom level 1
    ├── mg-poc-platform              # Custom level 2
    │   └── mg-poc-identity          # Custom level 3
    └── mg-poc-workloads             # Custom level 2
        └── mg-poc-dev                # Custom level 3
```

It does **not** create VMs, VNets, resource groups, policies, role assignments, or subscriptions.

## Prerequisites

- Terraform CLI 1.5+
- Azure CLI
- An Azure account and subscription in the target Microsoft Entra tenant
- Permission to create management groups. If tenant hierarchy protection is enabled, your identity needs the required management-group write permissions. A Management Group Contributor role is commonly appropriate when assigned at a sufficient scope.

## 1. Sign in to Azure

```bash
az login
az account list --output table
az account set --subscription "<YOUR-SUBSCRIPTION-ID>"
az account show --query "{name:name, subscriptionId:id, tenantId:tenantId}" --output table
```

Use a subscription in the tenant where you want to create the management groups.

## 2. Configure variables

Copy the example file:

**Linux/macOS**
```bash
cp terraform.tfvars.example terraform.tfvars
```

**PowerShell**
```powershell
Copy-Item terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` and replace the placeholder `subscription_id` with your actual subscription ID.

## 3. Initialize and validate

```bash
terraform init
terraform fmt -recursive
terraform validate
```

## 4. Preview and deploy

```bash
terraform plan -out main.tfplan
terraform apply main.tfplan
```

Review the plan before applying. Management groups are tenant-level governance objects, so confirm that you are signed into the intended tenant.

## 5. Verify

```bash
az account management-group list --output table
terraform output hierarchy_summary
terraform output management_group_hierarchy
```

Azure may take a short time to display hierarchy changes in every portal view.

## 6. Destroy (only if you really want to remove the POC)

```bash
terraform plan -destroy
terraform destroy
```

Terraform can only delete these custom management groups if they have no child management groups or subscriptions. If a group has subscriptions or other children, move/remove those first. Never attempt to delete Azure's built-in Tenant Root Group.

## Troubleshooting

- **AuthorizationFailed / managementGroups/write**: your identity lacks permission to create or manage management groups, or tenant hierarchy protection is enabled. Ask the tenant administrator to grant the required permission at the correct scope.
- **Wrong tenant**: run `az account show` and confirm the tenant ID before applying.
- **Provider subscription ID error**: make sure `terraform.tfvars` contains the correct `subscription_id`.
- **Management group already exists**: choose a unique `name_prefix`, or import/manage the existing group rather than trying to recreate it.

## Files

- `versions.tf` — Terraform and AzureRM provider versions/configuration
- `variables.tf` — input variables
- `main.tf` — management group resources
- `outputs.tf` — IDs and hierarchy summary
- `terraform.tfvars.example` — example variable values
