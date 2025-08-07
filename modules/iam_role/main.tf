##################################################################
locals {
  iam_role_policy_attachment = {
    for iam_role_policy in var.iam_role_policy_attachment : iam_role_policy.role => iam_role_policy
  }

  iam_role = {
    for iam_role in var.iam_role : iam_role.name => iam_role
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
  for_each = local.iam_role_policy_attachment

  role       = each.value.role
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_role.backup_role]
}
##################################################################