output "org_onboarding_id" {
  description = "The organization onboarding ID (use this when adding member accounts)"
  value       = module.cce_org.org_onboarding_id
}

output "secrets_hub_role_arn" {
  description = "The IAM role ARN created for Secrets Hub"
  value       = module.cce_org.secrets_hub_role_arn
}

output "secrets_manager_regions" {
  description = "List of AWS regions where Secrets Hub can manage secrets"
  value       = var.secrets_manager_regions
}

output "cce_scan_role_arn" {
  description = "The IAM role ARN for CCE organization scanning"
  value       = module.cce_org.cce_scan_role_arn
}
