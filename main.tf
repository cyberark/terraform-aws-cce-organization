data "aws_caller_identity" "current" {}

locals {
  account_id                 = data.aws_caller_identity.current.account_id
  deploy_prefix              = "CCE"
  role_external_id           = "${local.deploy_prefix}-${data.idsec_cce_aws_tenant_service_details.get_tenant_data.tenant_id}"
  organization_display_name  = var.display_name == null ? var.organization_id : var.display_name
  at_least_1_service_enabled = var.sca.enable == true || var.sia.enable == true

  # Validation: Ensure this module is deployed from Management Account
  is_management_account = local.account_id == var.management_account_id
}

# Fail early if not deploying from Management Account
resource "terraform_data" "validate_management_account" {
  input = local.is_management_account
  count = local.at_least_1_service_enabled ? 1 : 0

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

data "idsec_cce_aws_tenant_service_details" "get_tenant_data" {}

module "cce" {
  source                         = "./services_modules/cce"
  deploy_prefix                  = local.deploy_prefix
  cce_aws_account_number         = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.cce.service_account_id
  cross_account_role_external_id = local.role_external_id
  count                          = local.at_least_1_service_enabled ? 1 : 0
}

module "sia" {
  source                 = "./services_modules/sia"
  dpa_service_account_id = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.dpa.service_account_id
  tenant_id              = data.idsec_cce_aws_tenant_service_details.get_tenant_data.tenant_id
  count                  = var.sia.enable != false ? 1 : 0

}

module "sca" {
  source                 = "./services_modules/sca"
  sca_service_stage      = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.sca.service_stage
  sca_service_account_id = data.idsec_cce_aws_tenant_service_details.get_tenant_data.services_details.sca.service_account_id
  tenant_id              = data.idsec_cce_aws_tenant_service_details.get_tenant_data.tenant_id
  sso_enable             = var.sca.sso_enable
  sso_region             = var.sca.sso_enable != false ? var.sca.sso_region : null
  custom_role_name       = var.sca.role_name
  count                  = var.sca.enable != false ? 1 : 0
}

# Wait 10 seconds after all modules complete to allow asynchronous processes to finish
resource "time_sleep" "wait_for_modules" {
  depends_on = [
    module.cce,
    module.sia,
    module.sca
  ]

  create_duration = "10s"
  count           = local.at_least_1_service_enabled ? 1 : 0
}

# Create AWS organization onboarding with CyberArk services
resource "idsec_cce_aws_organization" "create_org" {
  organization_id                = var.organization_id
  organization_display_name      = local.organization_display_name
  management_account_id          = var.management_account_id
  organization_root_id           = var.organization_root_id
  scan_organization_role_arn     = module.cce[0].deployed_resources.main
  cross_account_role_external_id = local.role_external_id
  count                          = local.at_least_1_service_enabled ? 1 : 0

  # Wait for sleep resource to complete (which waits for all modules + 5 seconds)
  depends_on = [time_sleep.wait_for_modules]

  services = concat(
    # Add sia service if enabled
    var.sia.enable != false ? [
      {
        service_name = "dpa"
        resources = {
          "DpaRoleArn" = module.sia[0].deployed_resources.main
        }
      }
    ] : [],

    # Add sca service if enabled
    var.sca.enable != false ? [
      {
        service_name = "sca"
        resources = {
          "scaPowerRoleArn" = module.sca[0].deployed_resources.main,
          "ssoEnable"       = var.sca.sso_enable,
          "ssoRegion"       = var.sca.sso_enable != false ? var.sca.sso_region : null
        }
      }
    ] : []
  )
}
