output "cce_scan_role_arn" {
  description = "IAM role ARN for CCE organization scanning"
  value       = module.cyberark_org.cce_scan_role_arn
}

output "dpa_role_arn" {
  description = "IAM role ARN for Secure Infrastructure Access (SIA) - note: output name uses 'dpa' for backward compatibility"
  value       = module.cyberark_org.dpa_role_arn
}

