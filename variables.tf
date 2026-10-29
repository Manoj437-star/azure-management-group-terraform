variable "subscription_id" {
  description = "Azure subscription ID used by the AzureRM provider for authentication/context. This configuration does not create or move subscriptions."
  type        = string
}

variable "name_prefix" {
  description = "Prefix used in management group IDs. Use lowercase letters, numbers, hyphens, and keep IDs unique within the tenant."
  type        = string
  default     = "mg-poc"
}

variable "organization_display_name" {
  description = "Display name for the top custom management group."
  type        = string
  default     = "POC Organization"
}

variable "platform_display_name" {
  description = "Display name for the platform management group."
  type        = string
  default     = "POC Platform"
}

variable "workloads_display_name" {
  description = "Display name for the workloads management group."
  type        = string
  default     = "POC Workloads"
}

variable "identity_display_name" {
  description = "Display name for the identity management group."
  type        = string
  default     = "POC Identity"
}

variable "dev_display_name" {
  description = "Display name for the development management group."
  type        = string
  default     = "POC Development"
}
