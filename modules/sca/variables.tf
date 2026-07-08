variable "sca_service_stage" {
  description = "The SCA Service stage to deploy the resources"
  type        = string
}

variable "sca_service_region" {
  description = "The SCA Service region to deploy the resources"
  type        = string

  validation {
    condition     = var.sca_service_region != null && var.sca_service_region != ""
    error_message = "sca_service_region must be a non-empty AWS region."
  }
}

variable "sca_service_account_id" {
  description = "The AWS account number for SCA account"
  type        = string
}

variable "tenant_id" {
  description = "The tenant id of deployer"
  type        = string

  validation {
    condition     = length(var.tenant_id) <= 43
    error_message = "tenant_id must be at most 43 characters so default SCARole-{account_id}-{tenant_id} IAM role names stay within the 64-character AWS limit."
  }
}

variable "sso_enable" {
  description = "AWS IAM Identity Center"
  type        = bool
  default     = false
}

variable "sso_region" {
  description = "AWS IAM Identity Center Region"
  type        = string
  default     = "us-east-1"
}

variable "custom_role_name" {
  description = "Optional IAM role name for SCA cross-account access. When null or empty, SCARole-{account_id}-{tenant_id} is used."
  type        = string
  default     = null
  nullable    = true
}

