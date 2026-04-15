# Example 1: Basic CCE Organization Onboarding

This example demonstrates the minimal configuration required to onboard an AWS organization to CCE (Connect Cloud Environments) with at least one service enabled.

## What This Example Does

* Onboards your AWS organization to CCE
* Creates an IAM role in the management account for organization scanning
* Enables CCE to discover and monitor accounts in your organization
* Enables SIA (Secure Infrastructure Access) - the minimum required service

## Prerequisites

* AWS management account credentials
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured - https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage

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

* IAM role: `cyberark_CceOrganizationScanRole`
* IAM policy: `cyberark_CceOrganizationScanPolicy`

### In AWS (Current Account)

* IAM role: `CyberArkDynamicPrivilegedAccess-{tenant-prefix}`
* IAM policy: `CyberarkJitAccountProvisioningPolicy-{tenant-prefix}`

### In CCE

* Organization registration in CCE
* Organization scanning configuration
* SIA service enabled for just-in-time privileged access

## Outputs

This example outputs:

* `cce_scan_role_arn`: The IAM role ARN created for CCE organization scanning
* `dpa_role_arn`: The IAM role ARN created for Secure Infrastructure Access (SIA) - note: output name uses 'dpa' for backward compatibility

## Next Steps

After successful deployment:

1. Verify the organization appears in your CCE console
2. CCE will begin scanning your organization structure
3. To enable additional services, see [full\_services](../full_services/) or [common\_use\_case](../common_use_case/)
