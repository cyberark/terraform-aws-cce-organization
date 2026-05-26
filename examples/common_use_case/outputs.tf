output "cce_scan_role_arn" {
  description = "IAM role ARN for CCE organization scanning"
  value       = module.cce_org.cce_scan_role_arn
}

output "sca_role_arn" {
  description = "IAM role ARN for Secure Cloud Access"
  value       = module.cce_org.sca_role_arn
}

