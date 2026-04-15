output "cce_scan_role_arn" {
  description = "IAM role ARN for CCE organization scanning"
  value       = module.cyberark_org.cce_scan_role_arn
}

output "sca_role_arn" {
  description = "IAM role ARN for Secure Cloud Access"
  value       = module.cyberark_org.sca_role_arn
}

