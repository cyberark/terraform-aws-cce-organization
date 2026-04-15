variable "organization_id" {
  description = "The AWS Organization ID"
  type        = string
}

variable "management_account_id" {
  description = "The AWS Management Account ID"
  type        = string
}

variable "organization_root_id" {
  description = "The AWS organization root account id"
  type        = string
}

variable "display_name" {
  description = "The display name for the AWS organization"
  type        = string
  default     = null
}

variable "sca_sso_enable" {
  description = "Enable AWS IAM Identity Center integration for SCA"
  type        = bool
  default     = false
}

variable "sca_sso_region" {
  description = "AWS IAM Identity Center region (required if sca_sso_enable is true)"
  type        = string
  default     = "us-east-1"
}

