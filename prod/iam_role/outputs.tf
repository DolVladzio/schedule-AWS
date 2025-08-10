##################################################################
output "iam_users" {
  value = { for user, arn in aws_iam_user.main : user => arn.arn }
}
##################################################################
output "backup_role_arns" {
  value       = {
    for name, arn in aws_iam_role.backup_role : name => arn.arn
  }
}
##################################################################