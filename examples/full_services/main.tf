terraform {
  required_version = ">= 1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.2.1"
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

  # Enable SIA (Secure Infrastructure Access)
  sia = {
    enable = true
  }

  # Enable SCA (Secure Cloud Access) with SSO
  sca = {
    enable     = true
    sso_enable = true
    sso_region = var.sca_sso_region
  }
}

