terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  required_version = ">= 1.8.5"
}

resource "random_uuid" "suffix" {}

resource "aws_iam_role" "cce_org_scan_role" {
  name = "${var.deploy_prefix}_CceOrganizationScanRole-${split("-", random_uuid.suffix.result)[0]}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "organizations.amazonaws.com"
        }
      },
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = "arn:aws:iam::${var.cce_aws_account_number}:root"
        }
        Condition = {
          "StringEquals" = {
            "sts:ExternalId" = var.cross_account_role_external_id
          }
        }
      },
    ]
  })
}

resource "aws_iam_policy" "cce_org_scan_policy" {
  name        = "${var.deploy_prefix}_CceOrganizationScanPolicy-${split("-", random_uuid.suffix.result)[0]}"
  description = "Policy to allow scanning the organization and list accounts"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Resource = "*"
        Action = [
          "organizations:List*",
          "organizations:Describe*",
          "cloudformation:Describe*",
          "cloudformation:Get*",
          "cloudformation:List*",
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cce_org_scan_attach" {
  role       = aws_iam_role.cce_org_scan_role.name
  policy_arn = aws_iam_policy.cce_org_scan_policy.arn
}
