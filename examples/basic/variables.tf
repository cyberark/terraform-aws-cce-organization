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

