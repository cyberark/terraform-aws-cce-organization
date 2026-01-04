# CyberArk AWS Organization Integration Module

Terraform module for integrating AWS Organizations with CyberArk's Connect Cloud Environments (CCE) and security services.

**⚠️ Important:** This module is designed for the AWS Management Account only. After deploying this module on your management account, use the separate "add account" module to onboard member accounts.

## Overview

This module automates the onboarding of your AWS Organization's Management Account into CyberArk's SaaS security platform, enabling:

* **Organization Discovery**: Automatic scanning and monitoring of your AWS Organization structure
* **Identity Security**: Federated access management through CyberArk Secure Cloud Access (SCA)
* **Privileged Access**: Just-in-time access to AWS resources with CyberArk Secure Infrastructure Access (SIA)
* **Secrets Management**: Centralized secrets lifecycle management with CyberArk Secrets Hub

The module creates the necessary IAM roles and policies in your AWS Management Account and registers your organization with CyberArk's services.

## Features

* ✅ Automated AWS Organization onboarding to CyberArk CCE
* ✅ Modular service enablement (CCE, SIA, SCA, Secrets Hub)
* ✅ Cross-account IAM role creation with secure external ID patterns
* ✅ Support for AWS IAM Identity Center (SSO) integration
* ✅ Multi-region Secrets Manager support
* ✅ Input validation for production safety
* ✅ Comprehensive outputs for integration with other modules

## Prerequisites

Before using this module, ensure you have:

### AWS Requirements

* **Access to the AWS Management Account** (this module must be deployed from the management account)

* Permissions to:

    * Create and manage IAM roles and policies
    * Read AWS Organizations information
    * (Optional) Manage AWS IAM Identity Center for SCA SSO

* AWS Organization ID, Management Account ID, and Root ID

* AWS CLI or appropriate credentials configured for the management account

### CyberArk Requirements

* Active CyberArk tenant with desired services enabled
* CyberArk `idsec` provider credentials configured
* Tenant ID and service account details from CyberArk console

### Terraform Requirements

* Terraform >= 1.8.5
* AWS Provider >= 5.0.0
* CyberArk IDSec Provider >= 0.1.3

## Quick Start

**⚠️ Deploy this module from your AWS Management Account only.** For member accounts, use the separate "add account" module.

### Basic Usage (Management Account)

```hcl
module "cyberark_org" {
  source = "path/to/terraform-aws-cce-organization"

  organization_id       = "o-1234567890"
  management_account_id = "123456789012"
  organization_root_id  = "r-abcd"
  display_name          = "My Organization"
}
```

### Common Production Setup

```hcl
module "cyberark_org" {
  source = "path/to/terraform-aws-cce-organization"

  organization_id       = "o-1234567890"
  management_account_id = "123456789012"
  organization_root_id  = "r-abcd"
  display_name          = "My Organization"

  # Enable Secure Cloud Access
  sca = {
    enable     = true
    sso_enable = false
  }

  # Enable Secrets Hub for multiple regions
  secrets_hub = {
    enable                  = true
    secrets_manager_regions = "us-east-1,us-west-2,eu-west-1"
  }
}
```

See the [examples](./examples) directory for more detailed configurations.

## Examples

Three production-ready examples are provided:

| Example | Description | Use Case |
|---------|-------------|----------|
| [basic](./examples/basic/) | CCE + SIA | Initial onboarding and organization discovery |
| [full\_services](./examples/full_services/) | All services enabled | Comprehensive security coverage |
| [common\_use\_case](./examples/common_use_case/) | CCE + SCA + Secrets Hub | Typical enterprise deployment |

## Services

### CCE (Connect Cloud Environments)

**Automatically Enabled** - Required for organization onboarding.

**Management Account Only** - This service is only deployed when running from the management account.

Creates an IAM role in the Management Account for:

* Scanning organization structure
* Discovering member accounts
* Monitoring organization changes

**Resources Created**:

* IAM Role: `cyberark_CceOrganizationScanRole`
* IAM Policy: `cyberark_CceOrganizationScanPolicy`

### SIA (Secure Infrastructure Access)

**Optional** - Enable for just-in-time privileged access to EC2 instances.

```hcl
sia = {
  enable = true
}
```

**Resources Created**:

* IAM Role: `CyberArkDynamicPrivilegedAccess-{tenant-prefix}`
* Permissions for EC2 instance discovery and region scanning

**Use Cases**:

* Just-in-time SSH/RDP access to EC2 instances
* Session recording and auditing
* Zero standing privileges for privileged access

**Note**: SIA was previously called DPA (Dynamic Privileged Access). The service name "dpa" is still used internally for backward compatibility.

### SCA (Secure Cloud Access)

**Optional** - Enable for identity federation and access management.

```hcl
sca = {
  enable     = true
  sso_enable = false  # Set to true for AWS IAM Identity Center integration
  sso_region = "us-east-1"  # Required if sso_enable = true
}
```

**Resources Created**:

* IAM Role: `CyberArkRoleSCATerraform-{account-id}`
* IAM Policy for SAML provider and role management
* (Optional) IAM Policy for AWS IAM Identity Center integration

**Use Cases**:

* Federated access to AWS Console and CLI
* Centralized identity management
* Integration with AWS IAM Identity Center

### Secrets Hub

**Optional** - Enable for centralized secrets management.

```hcl
secrets_hub = {
  enable                  = true
  secrets_manager_regions = "us-east-1,us-west-2,eu-west-1"
}
```

**Resources Created**:

* IAM Role: `CyberArk-Secrets-Hub-AllowSecretsAccessRole-{random}`
* Region-restricted permissions for Secrets Manager
* Tag-based access control

**Use Cases**:

* Sync secrets between CyberArk and AWS Secrets Manager
* Centralized secrets lifecycle management
* Multi-region secrets distribution

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `organization_id` | AWS Organization ID | `string` | Yes | - |
| `management_account_id` | AWS Management Account ID | `string` | Yes | - |
| `organization_root_id` | AWS Organization root ID | `string` | Yes | - |
| `display_name` | Display name for the organization | `string` | No | `null` |
| `sia` | SIA configuration | `object` | No | `null` |
| `sca` | SCA configuration | `object` | No | `null` |
| `secrets_hub` | Secrets Hub configuration | `object` | No | `null` |

### Service Configuration Objects

#### SIA Configuration

```hcl
sia = {
  enable = bool  # Enable Secure Infrastructure Access
}
```

#### SCA Configuration

```hcl
sca = {
  enable     = bool    # Enable Secure Cloud Access
  sso_enable = bool    # Enable AWS IAM Identity Center integration
  sso_region = string  # IAM Identity Center region (required if sso_enable = true)
}
```

#### Secrets Hub Configuration

```hcl
secrets_hub = {
  enable                  = bool    # Enable Secrets Hub
  secrets_manager_regions = string  # Comma-separated list of AWS regions
}
```

## Outputs

| Name | Description |
|------|-------------|
| `cce_scan_role_arn` | IAM role ARN for CCE organization scanning (created in Management Account) |
| `dpa_role_arn` | IAM role ARN for Secure Infrastructure Access (SIA) - note: output name uses 'dpa' for backward compatibility |
| `sca_role_arn` | IAM role ARN for Secure Cloud Access |
| `secrets_hub_role_arn` | IAM role ARN for Secrets Hub |

## Security Considerations

### External ID Pattern

This module implements secure external ID patterns to prevent confused deputy attacks:

* **CCE**: `cyberark-{tenant-id}`
* **SIA**: `{tenant-id}`
* **SCA**: `{tenant-id}-{account-id}`

External IDs are automatically generated and should not be shared publicly.

### IAM Permissions

All IAM policies follow the principle of least privilege:

* **CCE**: Read-only access to Organizations and CloudFormation
* **SIA**: Read-only access to EC2 instances and regions
* **SCA**: Role and SAML provider management
* **Secrets Hub**: Tag-based and region-restricted Secrets Manager access

### Trust Relationships

All IAM roles use specific principal ARNs and conditional access:

* Principal ARN matching (not wildcard)
* External ID validation
* (Where applicable) Role pattern matching

## Deployment Workflow

### Step 1: Deploy on Management Account

**This module must be deployed from the AWS Management Account first.** It will:

1. Create the CCE organization scanning role in the management account
2. Register your organization with CyberArk CCE
3. Enable selected services (SIA, SCA, Secrets Hub) for the management account
4. Set up cross-account access for CyberArk services

### Step 2: Deploy on Member Accounts

After successfully deploying this module on the management account, use the **separate "add account" module** to onboard each member account in your organization. The add account module will:

* Create service-specific IAM roles in each member account
* Register each account with CyberArk
* Enable the same services configured in the management account

**Do not use this module on member accounts** - use the dedicated add account module instead.

### Regional Considerations

* The module can be deployed from any AWS region
* Service modules create global IAM resources
* Secrets Hub permissions are restricted to specified regions

## Validation

After deployment, verify:

1. **AWS Console**: Check that IAM roles and policies were created
2. **CyberArk Console**: Verify organization appears with enabled services
3. **Terraform Output**: Review all output values for correctness
4. **CloudTrail**: Monitor for any permission errors

## Troubleshooting

### Common Issues

**Issue**: "Organization ID must be valid format"

* **Solution**: Ensure organization\_id matches pattern `o-[a-z0-9]{10,32}`

**Issue**: "sso\_region is required when sso\_enable is set to true"

* **Solution**: Provide sso\_region when enabling SCA SSO integration

**Issue**: CCE role not created

* **Solution**: This module must be deployed from the Management Account. If you're deploying from a member account, use the separate "add account" module instead.

**Issue**: Provider authentication errors

* **Solution**: Verify CyberArk `idsec` provider credentials are configured

## Migration and Upgrades

### Upgrading from Previous Versions

If migrating from an earlier version:

1. Review the CHANGELOG for breaking changes
2. Run `terraform plan` to review changes
3. Test in a non-production environment first
4. Apply changes during a maintenance window

### State Management

* Use remote state (S3, Terraform Cloud) for production deployments
* Enable state locking to prevent concurrent modifications
* Regular state backups are recommended

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.8.5 |
| aws | >= 5.0.0 |
| idsec | >= 0.1.3 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0.0 |
| idsec | >= 0.1.3 |

## Modules

This module includes the following sub-modules:

* `services_modules/cce` - CCE organization scanning
* `services_modules/sia` - Secure Infrastructure Access
* `services_modules/sca` - Secure Cloud Access
* `services_modules/secrets_hub` - Secrets Hub integration

## Documentation

* [Module Documentation](./MODULE_DOCUMENTATION.md) - Comprehensive technical documentation
* [Contributing Guidelines](./CONTRIBUTING.md) - How to contribute
* [Security Policy](./SECURITY.md) - Security vulnerability reporting
* [License](./LICENSE) - Apache License 2.0

## Support

For issues and questions:

* **Security Issues**: Report to `product_security@cyberark.com`
* **General Issues**: Open an issue in the repository
* **CyberArk Support**: Contact your CyberArk representative

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](./CONTRIBUTING.md) for details on:

* How to submit issues
* How to submit pull requests
* Code style guidelines
* Review process

## Licensing

This repository is subject to the following licenses:

* **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE))
* **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf)

See [NOTICES.txt](./NOTICES.txt) for third-party license information.

## About CyberArk

CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).

***

**Version**: 0.0.0  
**Last Updated**: 2025-01-27
