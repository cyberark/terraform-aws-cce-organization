data "aws_caller_identity" "current" {}

locals {
  account_id       = data.aws_caller_identity.current.account_id
  deploy_prefix    = "cyberark"
  role_external_id = "${local.deploy_prefix}-placeholder-tenant-id"

  # Validation: Ensure this module is deployed from Management Account
  is_management_account = local.account_id == var.management_account_id
}

# Fail early if not deploying from Management Account
resource "terraform_data" "validate_management_account" {
  input = local.is_management_account

  lifecycle {
    precondition {
      condition     = local.is_management_account
      error_message = <<-EOT
        ERROR: This module must be deployed from the AWS Management Account.
        Expected Management Account ID: ${var.management_account_id}
        Current Account ID: ${local.account_id}
        
        For member accounts, use the separate "add account" module instead.
      EOT
    }
  }
}

module "cce" {
  source                         = "./services_modules/cce"
  deploy_prefix                  = local.deploy_prefix
  cce_aws_account_number         = "123456789012"
  cross_account_role_external_id = local.role_external_id
}
