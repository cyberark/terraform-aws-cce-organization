# Example: Basic CCE Organization Onboarding

This example demonstrates the minimal configuration required to onboard an AWS Organization to CyberArk CCE (Connect Cloud Environments).

## What This Example Does

* Onboards your AWS Organization to CyberArk CCE
* Creates an IAM role in the Management Account for organization scanning
* Enables CCE to discover and monitor accounts in your organization

## Prerequisites

* AWS Management Account credentials
* CyberArk tenant with CCE service enabled
* Terraform >= 1.8.5

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

### In AWS (Management Account)

* IAM Role: `cyberark_CceOrganizationScanRole`
* IAM Policy: `cyberark_CceOrganizationScanPolicy`

### In CyberArk

* Organization registration in CCE
* Organization scanning configuration

## Outputs

This example outputs:

* `cce_scan_role_arn`: The ARN of the created IAM role for CCE organization scanning

## Next Steps

After successful deployment:

1. Verify the organization appears in your CyberArk CCE console
2. CCE will begin scanning your organization structure
