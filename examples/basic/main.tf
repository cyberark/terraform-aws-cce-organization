terraform {
  required_version = ">= 1.8.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "cyberark_org" {
  source = "../../"

  organization_id       = var.organization_id
  management_account_id = var.management_account_id
  organization_root_id  = var.organization_root_id
  display_name          = var.display_name
}

