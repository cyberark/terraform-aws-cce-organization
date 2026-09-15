output "deployed_resources" {
  description = "Map of deployed resource ARNs and configuration"
  value = {
    main                          = aws_iam_role.sca_cross_account_assume_role.arn
    ssoEnable                     = var.sso_enable
    ssoRegion                     = var.sso_region
    addPermissionsToManageCluster = var.add_permissions_to_manage_cluster
  }
}

output "module_ready" {
  description = "List of resource identifiers indicating the module is ready"
  value = compact([
    aws_iam_role.sca_cross_account_assume_role.arn,
    aws_iam_policy.sca_cross_account_policy.arn,
    one(aws_iam_policy.sca_account_permissions_policy[*].arn),
    one(aws_iam_policy.sca_cross_account_sso_policy[*].arn),
    aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_policy.id,
    one(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_account_permissions_policy[*].id),
    one(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_sso_policy[*].id),
    try(aws_iam_policy.sca_eks_cluster_permissions_policy[0].arn, null),
    try(aws_iam_role_policy_attachment.sca_cross_account_role_attached_to_eks_cluster_policy[0].id, null)
  ])
}
