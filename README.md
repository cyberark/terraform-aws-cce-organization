# CCE AWS Organization Onboarding Module

This Terraform module onboards AWS organizations to Connect Cloud Environments (CCE) with CyberArk SaaS services.
CCE helps customers easily adopt CyberArk services and establish secure trust relationships with their AWS environments.

**⚠️ Important:** This module is designed for the AWS management account only. After deploying this module on your management account, use the separate "add account" module to onboard member accounts.

## Overview

This module automates the onboarding of your AWS organization's management account into the SaaS security platform, enabling:

* **Organization Discovery**: Automatic scanning and monitoring of your AWS organization structure
* **Identity Security**: Federated access management through Secure Cloud Access (SCA)
* **Privileged Access**: Just-in-time access to AWS resources with Secure Infrastructure Access (SIA)

This module creates the necessary IAM roles and policies in your AWS management account and registers your organization with the selected services.

## Features

* ✅ Automated AWS organization onboarding to CCE
* ✅ Modular service enablement (CCE, SIA, SCA)
* ✅ Cross-account IAM role creation with secure external ID patterns
* ✅ Support for AWS IAM Identity Center (SSO) integration
* ✅ Input validation for production safety
* ✅ Comprehensive outputs for integration with other modules

## Prerequisites

Before using this module, ensure that you have the following information and requirements:

1. **CyberArk Identity Security Platform Account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **AWS Requirements**
   - Access to the AWS management account (this module must be deployed from the management account)
   - AWS organization ID, management account ID, and root ID
   - Permissions to create and manage IAM roles and policies
   - Permissions to read AWS organization information
   - (Optional) Permissions to manage AWS IAM Identity Center for SCA SSO
   - AWS CLI or appropriate credentials configured for the management account

3. **Terraform Requirements**
   - Terraform >= 1.8.5
   - AWS Provider >= 5.0.0
   - CyberArk idsec Provider >= 0.1.3

## Quick Start

**⚠️ Deploy this module from your AWS management account only.** For member accounts, use the separate "add account" module.

### Basic Usage with SIA (Management Account)

```hcl
module "cyberark_org" {
  source = "path/to/terraform-aws-cce-organization"

  organization_id       = "o-1234567890"
  management_account_id = "123456789012"
  organization_root_id  = "r-abcd"
  display_name          = "My Organization"

  # Enable Secure Infrastructure Access
  sia = {
    enable = true
  }
}
```

### Production Setup with SCA

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
}
```

See the [examples](./examples) directory for more detailed configurations.

## Examples

Three production-ready examples are provided:

| Example | Description | Use Case |
|---------|-------------|----------|
| [basic](./examples/basic/) | SIA only | Initial onboarding with just-in-time privileged access |
| [full\_services](./examples/full_services/) | SIA + SCA with SSO | Comprehensive security coverage |
| [common\_use\_case](./examples/common_use_case/) | SCA only | Typical enterprise deployment with cloud entitlements management |

## Services

### CCE (Connect Cloud Environments)

**Automatically Enabled** - Required for organization onboarding.

**Management Account Only** - This service is only deployed when running from the management account.

Creates an IAM role in the management account for:

* Scanning organization structure
* Discovering member accounts
* Monitoring organization changes

**Resources Created**:

* IAM role: `cyberark_CceOrganizationScanRole-{unique-suffix}`
* IAM policy: `cyberark_CceOrganizationScanPolicy`

### SIA (Secure Infrastructure Access)

**Optional** - Enable for just-in-time privileged access to EC2 instances.

```hcl
sia = {
  enable = true
}
```

**Resources Created**:

* IAM role: `CyberArkSIA-{unique-suffix}`
* IAM policy: `CyberarkJitAccountProvisioningPolicy-{tenant-prefix}-{unique-suffix}`
* Permissions for EC2 instance discovery and region scanning

**Use Cases**:

* Just-in-time SSH/RDP access to EC2 instances
* Session recording and auditing
* Zero standing privileges for privileged access

**Note**: SIA was previously called DPA (Dynamic Privileged Access). The name "dpa" is still used internally for backward compatibility.

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

* IAM role: `CyberArkRoleSCA-{account-id}`
* IAM policy for SAML provider and role management
* (Optional) IAM policy for AWS IAM Identity Center integration

**Use Cases**:

* Federated access to AWS Console and CLI
* Centralized identity management
* Integration with AWS IAM Identity Center

## Inputs

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `organization_id` | AWS organization ID | `string` | Yes | - |
| `management_account_id` | AWS management account ID | `string` | Yes | - |
| `organization_root_id` | AWS organization root ID | `string` | Yes | - |
| `display_name` | Display name for the organization | `string` | No | `null` |
| `sia` | SIA configuration | `object` | No | `{ enable = false }` |
| `sca` | SCA configuration | `object` | No | `{ enable = false, sso_enable = false, sso_region = null }` |

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

## Outputs

| Name | Description |
|------|-------------|
| `org_onboarding_id` | The AWS organization onboarding ID from CCE (use this ID when adding accounts to the organization) |
| `cce_scan_role_arn` | The IAM role ARN for CCE organization scanning (created in management account) |
| `dpa_role_arn` | The IAM role ARN created for Secure Infrastructure Access (SIA) - note: output name uses 'dpa' for backward compatibility |
| `sca_role_arn` | The IAM role ARN created for Secure Cloud Access |

## Security Considerations

### External ID Pattern

This module implements secure external ID patterns to prevent confused deputy attacks:

* **CCE**: `cyberark-{tenant-id}`
* **SIA**: `{tenant-id}`
* **SCA**: `{tenant-id}-{account-id}`

External IDs are automatically generated and should not be shared publicly.

### IAM Permissions

All IAM policies follow the principle of least privilege:

* **CCE**: Read-only access to organizations and CloudFormation template
* **SIA**: Read-only access to EC2 instances and regions
* **SCA**: Role and SAML provider management

### Trust Relationships

All IAM roles use specific principal ARNs and conditional access:

* Principal ARN matching (not wildcard)
* External ID validation
* (Where applicable) Role pattern matching

## Deployment Workflow

### Step 1: Deploy to Management Account

**This module must be deployed from the AWS management account first.** It will:

1. Create the CCE organization scanning role in the management account
2. Register your organization with CCE
3. Enable selected services (SIA, SCA) for the management account
4. Set up cross-account access for services

### Step 2: Deploy to Member Accounts

After successfully deploying this module to the management account, use the **separate "add account" module** to onboard each member account in your organization. The add account module will:

* Create service-specific IAM roles in each member account
* Register each account with CCE
* Enable the same services configured in the management account

**Do not use this module on member accounts** - use the dedicated add account module instead.

### Regional Considerations

* The module can be deployed from any AWS region
* Service modules create global IAM resources

## Module Deletion

**⚠️ Important! When removing your organization from CCE, you must perform the steps in the following order. **

1. Delete all member accounts.
You must first delete all member accounts that were added using the "add account" module. This ensures a clean removal of all resources.

2. Delete the management account.
After you have deleted the module from all member accounts, run the 'terraform destroy' on this module to delete the management account and complete the removal of the organization from CCE.

* You can also delete this module by removing it from your main.tf file or set all the services' enable flag to false.

**What Gets Deleted**:

When you delete the organization using this module, you remove the following:
* All IAM roles and policies created in this module
* The entire organization from the CCE platform
* All associated accounts from CCE 

**Important Notes**:
If you delete the organization's management account first, before deleting the member accounts, this may result in orphaned resources.
Always verify that all member accounts have been deleted before removing the organization's management account.


## Validation

After deployment, verify:

1. **AWS Console**: Check that IAM roles and policies were created
2. **CCE Console**: Verify that the organization appears with enabled services
3. **Terraform Output**: Review and verify all output values
4. **CloudTrail**: Monitor for any permission errors

## Troubleshooting

### Common Issues

**Issue**: "Organization ID must be valid format"

* **Solution**: Ensure organization\_id matches pattern `o-[a-z0-9]{10,32}`

**Issue**: "sso\_region is required when sso\_enable is set to true"

* **Solution**: Provide sso\_region when enabling SCA SSO integration

**Issue**: CCE role not created

* **Solution**: This module must be deployed from the management account. If you're deploying from a member account, use the separate "add account" module instead.

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