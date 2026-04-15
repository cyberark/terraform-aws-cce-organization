# ============================================
# REQUIRED VARIABLES
# ============================================

variable "organization_id" {
  description = "The AWS Organization ID"
  type        = string

  validation {
    condition     = can(regex("^o-[a-z0-9]{10,32}$", var.organization_id))
    error_message = "Organization ID must be valid format (o-xxxxxxxxxx)."
  }
}

variable "management_account_id" {
  description = "The AWS Management Account ID"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.management_account_id))
    error_message = "Management Account ID must be a 12-digit AWS account ID."
  }
}

variable "organization_root_id" {
  description = "The AWS organization root account id"
  type        = string

  validation {
    condition     = can(regex("^r-[a-z0-9]{4,32}$", var.organization_root_id))
    error_message = "Organization root ID must be valid format (r-xxxx)."
  }
}

# ============================================
# OPTIONAL CONFIGURATION
# ============================================

variable "display_name" {
  description = "The display name for the AWS organization"
  type        = string
  default     = null
}

# ============================================
# SERVICE FEATURE FLAGS
# ============================================

variable "sia" {
  description = "Configuration for the SIA (Secure Infrastructure Access / Dynamic Privileged Access) feature."
  type = object({
    enable = optional(bool, true)
  })
  default = {
    enable = false
  }
}

variable "sca" {
  description = "Configuration for the SCA (Secure Cloud Access) feature."
  type = object({
    enable     = optional(bool, true)
    sso_enable = optional(bool, false)
    sso_region = optional(string, null)
    role_name  = optional(string, null)
  })
  default = {
    enable     = false
    sso_enable = false
    sso_region = null
  }

  validation {
    condition     = var.sca.sso_enable == false ? true : var.sca.sso_region != null
    error_message = "sso_region is required when sso_enable is set to true."
  }
}

