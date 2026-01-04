# ============================================
# REQUIRED VARIABLES
# ============================================

variable "management_account_id" {
  description = "The AWS Management Account ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "Management Account ID must be a 12-digit AWS account ID."
  }
}

