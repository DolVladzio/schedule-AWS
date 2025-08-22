##################################################################
output "iam_users" {
  value = { for user, arn in aws_iam_user.main : user => arn.arn }
}
##################################################################
output "iam_user_groups" {
  value = { for user, group in aws_iam_user_group_membership.main : user => flatten(group.groups) }
}
##################################################################
output "iam_groups" {
  value = { for group, arn in aws_iam_group.main : group => arn.arn }
}
##################################################################
output "backup_role_arns" {
  value = { for name, arn in aws_iam_role.allow : name => arn.arn }
}
##################################################################