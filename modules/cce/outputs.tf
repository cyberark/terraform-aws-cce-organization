output "deployed_resources" {
  description = "Map of deployed resource ARNs"
  value       = { main = aws_iam_role.cce_org_scan_role.arn }
}

output "module_ready" {
  description = "List of resource identifiers indicating the module is ready"
  value = [
    aws_iam_role.cce_org_scan_role.arn,
    aws_iam_policy.cce_org_scan_policy.arn,
    aws_iam_role_policy_attachment.cce_org_scan_attach.id,
  ]
}

