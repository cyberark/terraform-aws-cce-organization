# Example 3: Common Use Case - Enterprise Security Setup

This example demonstrates a typical production configuration that most enterprises deploy: CCE for visibility and SCA for secure access management.

## What This Example Does

* Onboards your AWS organization to CCE
* Enables **Secure Cloud Access (SCA)** for federated identity and access management
* **Does NOT** enable SIA (can be added later if needed)

## Why This Configuration

This is the most common deployment pattern because it provides:

1. **CCE**: Full visibility into your AWS organization structure and accounts
2. **SCA**: Enterprise-grade identity federation and access management

This combination addresses the core security needs for most organizations without the complexity of just-in-time privileged access (which can be added incrementally).

## Prerequisites

* AWS management account credentials
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured

## Services Configured

### CCE

Automatically enabled - provides organization scanning and account discovery.

### SCA (Secure Cloud Access)

* Creates IAM role for SAML provider and role management
* **SSO Integration**: Optional (disabled by default in this example)
* Enables federated access with CyberArk Identity management
* Manages IAM roles and policies for end users

## Usage

1. Update the values in `terraform.tfvars`:

    ```hcl
    organization_id       = "o-1234567890"
    management_account_id = "123456789012"
    organization_root_id  = "r-abcd"
    display_name          = "My organization"
    ```

2. (Optional) Enable SSO if you have AWS IAM Identity Center configured:

    ```hcl
    sca_sso_enable = true
    sca_sso_region = "us-east-1"
    ```

3. Initialize Terraform:

    ```bash
    terraform init
    ```

4. Review the plan:

    ```bash
    terraform plan
    ```

5. Apply the configuration:

    ```bash
    terraform apply
    ```

## What Gets Created

### In AWS

* **CCE**: IAM role in management account for organization scanning
* **SCA**: IAM role for identity and access management

### In CCE

* Organization registration with selected services
* Service configurations and cross-account access setup

## Customization Options

### Enable SSO Integration

If you use AWS IAM Identity Center, set:

```hcl
sca_sso_enable = true
sca_sso_region = "us-east-1"  # Your Identity Center region
```

### Add SIA Later

If you later need just-in-time privileged access for EC2:

```hcl
sia = {
  enable = true
}
```

## Next Steps

After successful deployment:

1. Verify services appear in your CCE console
2. Configure SCA policies for federated access
3. Set up user access policies in CyberArk Identity management
4. Monitor CCE for security insights

## Cost Considerations

This configuration:

* Creates IAM roles and policies (no direct AWS cost)
* Requires CyberArk service licenses
* Generates CloudTrail events for auditing
* More cost-effective than full services deployment
