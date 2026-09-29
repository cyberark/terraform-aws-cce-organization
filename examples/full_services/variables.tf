variable "organization_id" {
  description = "The AWS organization ID."
  type        = string
}

variable "management_account_id" {
  description = "The AWS management account ID."
  type        = string
}

variable "organization_root_id" {
  description = "The AWS organization root account ID."
  type        = string
}

variable "display_name" {
  description = "The display name for the AWS organization."
  type        = string
  default     = null
}

variable "sca_sso_region" {
  description = "AWS IAM Identity Center region for SCA SSO integration."
  type        = string
  default     = "us-east-1"
}

