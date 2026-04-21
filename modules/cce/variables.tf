variable "cce_aws_account_number" {
  description = "The AWS account number for cce account"
  type        = string
}

variable "deploy_prefix" {
  description = "Prefix for the resource created"
  type        = string
}

variable "cross_account_role_external_id" {
  description = "CCE cross account role external id"
  type        = string
}

