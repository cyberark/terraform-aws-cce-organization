output "org_onboarding_id" {
  description = "The AWS Organization Onboarding ID from CyberArk CCE (use this ID when adding accounts to the organization)"
  value       = try(idsec_cce_aws_organization.create_org[0].id, null)
}

output "cce_scan_role_arn" {
  description = "IAM role ARN for CCE organization scanning (deployed in Management Account only)"
  value       = try(module.cce[0].deployed_resources.main, null)
}

output "dpa_role_arn" {
  description = "IAM role ARN for Secure Infrastructure Access (SIA) - note: output name uses 'dpa' for backward compatibility"
  value       = try(module.sia[0].deployed_resources.main, null)
}

output "sca_role_arn" {
  description = "IAM role ARN for Secure Cloud Access"
  value       = try(module.sca[0].deployed_resources.main, null)
}

