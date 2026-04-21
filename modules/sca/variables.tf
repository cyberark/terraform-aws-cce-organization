variable "sca_service_stage" {
  description = "The SCA Service stage to deploy the resources"
  type        = string
}

variable "sca_service_account_id" {
  description = "The AWS account number for SCA account"
  type        = string
}

variable "tenant_id" {
  description = "The tenant id of deployer"
  type        = string
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
  description = "Optional IAM role name for SCA cross-account access. When null or empty, CyberArkSCACrossAccountRole is used."
  type        = string
  default     = null
  nullable    = true
}

