# Example 3: Common Use Case - Enterprise Security Setup

This example demonstrates a typical production configuration that most enterprises deploy: CCE for visibility, SCA for secure access management, and Secrets Hub for secrets management.

## What This Example Does

* Onboards your AWS Organization to CyberArk CCE
* Enables **Secure Cloud Access (SCA)** for federated identity and access management
* Enables **Secrets Hub** for centralized secrets management
* **Does NOT** enable SIA (can be added later if needed)

## Why This Configuration

This is the most common deployment pattern because it provides:

1. **CCE**: Full visibility into your AWS organization structure and accounts
2. **SCA**: Enterprise-grade identity federation and access management
3. **Secrets Hub**: Centralized secrets management across AWS regions

This combination addresses the core security needs for most organizations without the complexity of just-in-time privileged access (which can be added incrementally).

## Prerequisites

* AWS Management Account credentials
* CyberArk tenant with CCE, SCA, and Secrets Hub enabled
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured

## Services Configured

### CCE (Connect Cloud Environments)

Automatically enabled - provides organization scanning and account discovery.

### SCA (Secure Cloud Access)

* Creates IAM role for SAML provider and role management
* **SSO Integration**: Optional (disabled by default in this example)
* Enables federated access with CyberArk identity management
* Manages IAM roles and policies for end users

### Secrets Hub

* Creates IAM role for AWS Secrets Manager integration
* **Multi-Region**: Configured for your primary operating regions
* Tag-based access control for CyberArk-managed secrets
* Support for extended access scenarios

## Usage

1. Update the values in `terraform.tfvars`:

    ```hcl
    organization_id       = "o-1234567890"
    management_account_id = "123456789012"
    organization_root_id  = "r-abcd"
    display_name          = "My Organization"
    secrets_hub_regions   = "us-east-1,us-west-2"
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

* **CCE**: IAM role in Management Account for organization scanning
* **SCA**: IAM role for identity and access management
* **Secrets Hub**: IAM role for Secrets Manager access across specified regions

### In CyberArk

* Organization registration with selected services
* Service configurations and cross-account access setup

## Customization Options

### Enable SSO Integration

If you use AWS IAM Identity Center, set:

```hcl
sca_sso_enable = true
sca_sso_region = "us-east-1"  # Your Identity Center region
```

### Adjust Secrets Hub Regions

Update the comma-separated list to match your operational regions:

```hcl
secrets_hub_regions = "us-east-1,us-west-2,eu-west-1,ap-southeast-1"
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

1. Verify services appear in your CyberArk console
2. Configure SCA policies for federated access
3. Begin migrating secrets to Secrets Hub
4. Set up user access policies in CyberArk
5. Monitor CCE for security insights

## Cost Considerations

This configuration:

* Creates IAM roles and policies (no direct AWS cost)
* Requires CyberArk service licenses
* Generates CloudTrail events for auditing
* More cost-effective than full services deployment
