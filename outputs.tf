output "cce_scan_role_arn" {
  description = "IAM role ARN for CCE organization scanning (deployed in Management Account only)"
  value       = module.cce.deployed_resources.main
}

