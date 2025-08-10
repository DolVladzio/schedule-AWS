##################################################################
locals {
  iam_role = {
    for iam_role in var.iam_role : iam_role.name => iam_role
  }

  flattened_attachments = flatten([
    for item in var.iam_role : [
      for policy in item.policy_arn : {
        role       = item.name
        policy_arn = policy
      }
    ]
  ])

  iam_user_flattened_attachments = flatten([
    for item in var.iam_user : [
      for policy in item.policy_arn : {
        user       = item.user
        policy_arn = policy
      }
    ]
  ])

  iam_user = {
    for iam_user in var.iam_user : iam_user.user => iam_user
  }
}
##################################################################
resource "aws_iam_role" "backup_role" {
  for_each = local.iam_role

  name = each.value.name

  assume_role_policy = jsonencode({
    Version = each.value.version,
    Statement = [
      {
        Effect = each.value.effect,
        Principal = {
          Service = each.value.principal_service
        },
        Action = each.value.action
      }
    ]
  })
}
##################################################################
resource "aws_iam_role_policy_attachment" "backup_attach" {
  for_each = {
    for idx, val in local.flattened_attachments :
    "${val.role}-${basename(val.policy_arn)}" => val
  }

  role       = each.value.role
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_role.backup_role]
}
##################################################################
resource "aws_iam_user" "main" {
  for_each = local.iam_user

  name = each.value.user

  tags = { Name = each.value.tags }
}
##################################################################
resource "aws_iam_user_policy_attachment" "main" {
  for_each = {
    for idx, val in local.iam_user_flattened_attachments :
    "${val.user}-${basename(val.policy_arn)}" => val
  }

  user       = each.value.user
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_user.main]
}
##################################################################