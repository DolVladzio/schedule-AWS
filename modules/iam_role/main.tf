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

  iam_group_flattened_attachments = flatten([
    for item in var.iam_groups : [
      for policy in item.policy_arn : {
        name       = item.name
        path       = item.path
        policy_arn = policy
      }
    ]
  ])

  iam_user = {
    for iam_user in var.iam_user : iam_user.user => iam_user
  }
}
##################################################################
resource "aws_iam_role" "allow" {
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
resource "aws_iam_role_policy_attachment" "main" {
  for_each = {
    for idx, val in local.flattened_attachments :
    "${val.role}-${basename(val.policy_arn)}" => val
  }

  role       = each.value.role
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_role.allow]
}
##################################################################
resource "aws_iam_user" "main" {
  for_each = local.iam_user

  name = each.value.user
  tags = { Group = each.value.tags }

  depends_on = [aws_iam_group.main]
}
##################################################################
resource "aws_iam_user_group_membership" "main" {
  for_each = local.iam_user

  user = each.value.user
  groups = [
    for group in each.value.groups : aws_iam_group.main[group].name
  ]

  depends_on = [aws_iam_user.main]
}
##################################################################
resource "aws_iam_group" "main" {
  for_each = var.iam_groups

  name = each.value.name
  path = each.value.path
}
##################################################################
resource "aws_iam_group_policy_attachment" "admin_access" {
  for_each = {
    for idx, val in local.iam_group_flattened_attachments :
    "${val.name}-${basename(val.policy_arn)}" => val
  }

  group      = each.value.name
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_group.main]
}
##################################################################