##################################################################
output "iam_users" {
  value = { for user, arn in aws_iam_user.main : user => arn.arn }
}
##################################################################
output "iam_groups" {
  value = { for group, arn in aws_iam_group.main : group => arn.arn }
}
##################################################################
output "backup_role_arns" {
  value = { for name, arn in aws_iam_role.backup_role : name => arn.arn }
}
##################################################################