##################################################################
output "iam_users" {
  value = { for k, user in aws_iam_user.main : k => {
    user       = user.name
    policy_arn = user.arn
    }
  }
}
##################################################################