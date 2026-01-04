# Example 2: Full Services Deployment

This example demonstrates how to enable all CyberArk services for comprehensive security coverage across your AWS Organization.

## What This Example Does

* Onboards your AWS Organization to CyberArk CCE
* Enables **Secure Infrastructure Access (SIA)** for just-in-time access to EC2 instances
* Enables **Secure Cloud Access (SCA)** with AWS IAM Identity Center integration
* Enables **Secrets Hub** for centralized secrets management across multiple regions

## Prerequisites

* AWS Management Account credentials
* CyberArk tenant with all services enabled (CCE, SIA, SCA, Secrets Hub)
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured
* AWS IAM Identity Center configured (for SCA SSO integration)

## Services Configured

### CCE (Connect Cloud Environments)

Automatically enabled - provides organization scanning and account discovery.

### SIA (Secure Infrastructure Access)

* Creates IAM role for EC2 instance discovery
* Enables just-in-time privileged access to EC2 instances
* Provides session recording and auditing

### SCA (Secure Cloud Access)

* Creates IAM role for SAML provider and role management
* **SSO Integration**: Enabled with AWS IAM Identity Center
* Enables federated access with CyberArk identity management

### Secrets Hub

* Creates IAM role for AWS Secrets Manager integration
* **Multi-Region**: Enabled for us-east-1, us-west-2, and eu-west-1
* Allows CyberArk to sync and manage secrets across regions

## Usage

1. Update the values in `terraform.tfvars`:

    ```hcl
    organization_id       = "o-1234567890"
    management_account_id = "123456789012"
    organization_root_id  = "r-abcd"
    display_name          = "My Organization"
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

* **CCE**: IAM role in Management Account for organization scanning
* **SIA**: IAM role for EC2 instance discovery and access
* **SCA**: IAM role for identity and access management (with SSO permissions)
* **Secrets Hub**: IAM role for Secrets Manager access across specified regions

### In CyberArk

* Organization registration with all services enabled
* Service configurations and cross-account access setup

## Outputs

This example outputs all IAM role ARNs created by the module:

* `cce_scan_role_arn`: IAM role ARN for CCE organization scanning
* `dpa_role_arn`: IAM role ARN for Secure Infrastructure Access (SIA) - note: output name uses 'dpa' for backward compatibility
* `sca_role_arn`: IAM role ARN for Secure Cloud Access
* `secrets_hub_role_arn`: IAM role ARN for Secrets Hub

## Cost Considerations

Enabling all services will:

* Create multiple IAM roles and policies (no direct cost)
* Enable CyberArk services that may have licensing costs
* Generate CloudTrail events for auditing

## Next Steps

After successful deployment:

1. Verify all services appear in your CyberArk console
2. Configure service-specific policies and settings
3. Set up users and access policies in CyberArk
4. Test federated access through SCA
5. Begin onboarding secrets to Secrets Hub
