# Example: Secrets Hub Deployment

This example demonstrates how to enable Secrets Hub for centralized secrets management between PAM and AWS Secrets Manager.

## What This Example Does

* Onboards your AWS organization to CCE
* Enables **Secrets Hub** for centralized secrets synchronization
* Configures access to AWS Secrets Manager in specified regions

## Prerequisites

* AWS management account credentials
* Identity tenant with Secrets Hub enabled
* Terraform >= 1.8.5
* CyberArk `idsec` provider configured
* At least one AWS region for secrets management

## Services Configured

### CCE

Automatically enabled - provides organization scanning and account discovery.

### Secrets Hub

* Creates IAM role for AWS Secrets Manager access
* Enables secrets synchronization from PAM to AWS Secrets Manager
* Restricts secrets operations to specified AWS regions
* Automatically tags managed secrets for tracking

## What is Secrets Hub?

Secrets Hub provides centralized secrets management across cloud and on-premises environments:

* **Centralized Management**: Single source of truth for all secrets in PAM vault
* **Automated Synchronization**: Push secrets from PAM to AWS Secrets Manager automatically
* **Lifecycle Management**: Create, update, rotate, and delete secrets from PAM
* **Regional Control**: Specify which AWS regions can contain synchronized secrets
* **Audit & Compliance**: Complete audit trail of all secrets operations
* **Tag-Based Access**: Control which secrets PAM can manage using AWS tags

## Usage

1. Update the values in `terraform.tfvars`:

    ```hcl
    organization_id         = "o-1234567890"
    management_account_id   = "123456789012"
    organization_root_id    = "r-abcd"
    display_name            = "My Organization"
    secrets_manager_regions = ["us-east-1", "us-west-2", "eu-west-1"]
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
* **Secrets Hub**: IAM role with permissions to:
  - Create secrets in specified regions (with required tags)
  - List secrets in specified regions
  - Update, delete, and manage tagged secrets
  - Tag/untag secrets (limited to CyberArk-specific tags)
  - Read secret values (only for secrets tagged with `CyberArk Extended Access: true`)

### In CCE

* Organization registration with Secrets Hub enabled
* Service configurations and cross-account access setup

## Secrets Management

### Creating Secrets

Secrets created by Secrets Hub are automatically tagged with:
- `Sourced by CyberArk: ""` (empty value, required tag)

Only secrets with this tag can be managed by Secrets Hub.

### Extended Access

To allow Secrets Hub to read secret values (not just manage metadata), add the tag:
- `CyberArk Extended Access: true`

Without this tag, Secrets Hub can create, update, and delete secrets but cannot retrieve their values.

### Regional Restrictions

Secrets can only be created and managed in the AWS regions specified in `secrets_manager_regions`. Attempts to access secrets in other regions will be denied by IAM policies.

## Security Considerations

### IAM Permissions

The Secrets Hub IAM policy follows the principle of least privilege:

* **CreateSecret**: Only allowed with the required `Sourced by CyberArk` tag in specified regions
* **ListSecrets**: Limited to specified regions
* **UpdateSecret, PutSecretValue, DeleteSecret**: Only for secrets with the `Sourced by CyberArk` tag in specified regions
* **GetSecretValue**: Only for secrets tagged with both `Sourced by CyberArk` and `CyberArk Extended Access: true`
* **TagResource/UntagResource**: Limited to CyberArk-specific tags only

### External ID

The external ID for the trust relationship is automatically generated as `{tenant-id}-{account-id}` to prevent confused deputy attacks.

### Principal ARN

The IAM role trusts only the specific Secrets Hub global role ARN, not wildcard principals.

## Outputs

This example outputs:

* `org_onboarding_id`: Organization onboarding ID for adding member accounts
* `secrets_hub_role_arn`: IAM role ARN for Secrets Hub
* `secrets_manager_regions`: List of configured AWS regions

## Use Cases

### Scenario 1: Multi-Region Application

Deploy application secrets to multiple AWS regions for disaster recovery:

```hcl
secrets_manager_regions = ["us-east-1", "us-west-2", "eu-west-1"]
```

### Scenario 2: Single Region Deployment

Restrict secrets to a single region for compliance:

```hcl
secrets_manager_regions = ["us-gov-west-1"]
```

### Scenario 3: Development Environment

Use development-specific regions:

```hcl
secrets_manager_regions = ["us-east-1"]
```

## Cost Considerations

* IAM roles and policies have no direct cost
* AWS Secrets Manager charges apply for stored secrets
* Consider the number of secrets and regions when planning costs

## Next Steps

After successful deployment:

1. Verify the Secrets Hub service appears in your CCE console.
2. Configure secret synchronization policies in PAM.
3. Create secrets in PAM and sync to AWS Secrets Manager.
4. Test secret access from your applications.
5. Set up secret rotation policies as needed.
6. Use the output `org_onboarding_id` to onboard member accounts with the add-account module.

## Troubleshooting

**Issue**: Secrets cannot be created in a specific region

* **Solution**: Verify the region is included in `secrets_manager_regions`

**Issue**: Cannot read secret values

* **Solution**: Add the `CyberArk Extended Access: true` tag to the secret

**Issue**: Permission denied when managing secrets

* **Solution**: Verify the secret has the `Sourced by CyberArk` tag

## Additional Resources

* [AWS Secrets Manager Documentation](https://docs.aws.amazon.com/secretsmanager/)
* [AWS Secrets Manager Pricing](https://aws.amazon.com/secrets-manager/pricing/)
