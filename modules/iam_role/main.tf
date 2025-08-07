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