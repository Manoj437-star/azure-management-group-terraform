# Terraform Deployment Evidence

## Project
Enterprise Azure Governance POC

## Deployment Summary

The Terraform POC created the following Management Group hierarchy:

```text
Tenant Root Group
└── mg-poc-org
    ├── mg-poc-platform
    │   └── mg-poc-identity
    └── mg-poc-workloads
        └── mg-poc-dev
```

## Terraform Resources

- Five custom Management Groups.
- Custom required-tags Azure Policy definition.
- Custom approved public IP regions policy definition.
- Governance Policy Initiative.
- Management Group-level Policy Initiative assignment.

## Recorded Terraform Result

The policy deployment Terraform apply reported:

- Added: 4
- Changed: 0
- Destroyed: 0

The Management Group hierarchy was also deployed and verified during the POC.

## Validation Limitation

The POC subscription was not a descendant of `mg-poc-org`. Moving it was blocked by insufficient permissions. Therefore, end-to-end policy enforcement against that subscription was not validated.

## Evidence Status

Deployment configuration and Terraform execution were completed during the POC. Live Azure access is currently unavailable for additional verification.
