variable "organization_id" {
  description = "The AWS organization ID (format: o-xxxxxxxxxx)"
  type        = string
}

variable "management_account_id" {
  description = "The AWS management account ID"
  type        = string
}

variable "organization_root_id" {
  description = "The AWS organization root ID (format: r-xxxx)"
  type        = string
}

variable "display_name" {
  description = "Display name for the organization in CCE"
  type        = string
  default     = null
}

variable "secrets_manager_regions" {
  description = "List of AWS regions where Secrets Hub can create and manage secrets"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}
