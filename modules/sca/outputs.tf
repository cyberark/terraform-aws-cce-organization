output "deployed_resources" {
  description = "Map of deployed resource ARNs and configuration"
  value       = { main = aws_iam_role.cyberark_sca_cross_account_assume_role.arn, ssoEnable = var.sso_enable, ssoRegion = var.sso_region }
}

output "module_ready" {
  description = "List of resource identifiers indicating the module is ready"
  value = [
    aws_iam_role.cyberark_sca_cross_account_assume_role.arn,
    aws_iam_policy.cyberark_sca_cross_account_policy.arn,
    one(aws_iam_policy.cyberark_account_permissions_policy[*].arn),
    one(aws_iam_policy.cyberark_sca_cross_account_sso_policy[*].arn),
    aws_iam_role_policy_attachment.cyberark_sca_cross_account_role_attached_to_policy.id,
    one(aws_iam_role_policy_attachment.cyberark_sca_cross_account_role_attached_to_account_permissions_policy[*].id),
    one(aws_iam_role_policy_attachment.cyberark_sca_cross_account_role_attached_to_sso_policy[*].id)
  ]
}

