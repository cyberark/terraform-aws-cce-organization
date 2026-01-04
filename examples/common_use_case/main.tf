terraform {
  required_version = ">= 1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    idsec = {
      source  = "cyberark/idsec"
      version = ">= 1.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "idsec" {
  # Configure your CyberArk credentials here or via environment variables
  # See: https://registry.terraform.io/providers/cyberark/idsec/latest/docs
}

module "cyberark_org" {
  source = "../../"

  # Organization configuration
  organization_id       = var.organization_id
  management_account_id = var.management_account_id
  organization_root_id  = var.organization_root_id
  display_name          = var.display_name

  # Enable SCA (Secure Cloud Access)
  # SSO is optional - enable if you have AWS IAM Identity Center configured
  sca = {
    enable     = true
    sso_enable = var.sca_sso_enable
    sso_region = var.sca_sso_enable ? var.sca_sso_region : null
  }

  # Enable Secrets Hub with your operational regions
  secrets_hub = {
    enable                  = true
    secrets_manager_regions = var.secrets_hub_regions
  }

  # Note: SIA is not enabled in this common use case
  # It can be added later by chnage the value of enable to true:
  sia = {
    enable = false
  }
}

