# Example 2: Full Services Deployment

This example demonstrates how to enable all CyberArk services for comprehensive security coverage across your AWS organization.

## What This Example Does

* Onboards your AWS organization to CCE
* Enables **Secure Infrastructure Access (SIA)** for just-in-time access to EC2 instances
* Enables **Secure Cloud Access (SCA)** with AWS IAM Identity Center integration

## Prerequisites

* AWS management account credentials
* CyberArk tenant with all services enabled (CCE, SIA, SCA)
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured
* AWS IAM Identity Center configured (for SCA SSO integration)

## Services Configured

### CCE

Automatically enabled - provides organization scanning and account discovery.

### SIA (Secure Infrastructure Access)

* Creates IAM role for EC2 instance discovery
* Enables just-in-time privileged access to EC2 instances
* Provides session recording and auditing

### SCA (Secure Cloud Access)

* Creates IAM role for SAML provider and role management
* **SSO Integration**: Enabled with AWS IAM Identity Center
* Enables federated access with CyberArk Identity management

## Usage

1. Update the values in `terraform.tfvars`:

    ```hcl
    organization_id       = "o-1234567890"
    management_account_id = "123456789012"
    organization_root_id  = "r-abcd"
    display_name          = "My organization"
    ```

2. Initialize Terraform:

    ```bash
    terraform init
    ```

3. Review the plan:

    ```bash
    terraform plan
    ```

4. Apply the configuration:

    ```bash
    terraform apply
    ```

## What Gets Created

### In AWS

* **CCE**: IAM role in management account for organization scanning
* **SIA**: IAM role for EC2 instance discovery and access
* **SCA**: IAM role for identity and access management (with SSO permissions)

### In CCE

* Organization registration with all services enabled
* Service configurations and cross-account access setup

## Outputs

This example outputs all IAM role ARNs created by the module:

* `cce_scan_role_arn`: IAM role ARN for CCE organization scanning
* `dpa_role_arn`: IAM role ARN for Secure Infrastructure Access (SIA) - note: output name uses 'dpa' for backward compatibility
* `sca_role_arn`: IAM role ARN for Secure Cloud Access

## Cost Considerations

Enabling all services will:

* Create multiple IAM roles and policies (no direct cost)
* Enable services that may have licensing costs
* Generate CloudTrail events for auditing

## Next Steps

After successful deployment:

1. Verify all services appear in your CCE console
2. Configure service-specific policies and settings
3. Set up users and access policies in CyberArk Identity management
4. Test federated access through SCA
