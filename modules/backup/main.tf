##################################################################
locals {
  backup_vault = {
    for backup_vault in var.aws_backup_plan : backup_vault.name => backup_vault
  }

  backup_selection = {
    for backup_selection in var.aws_backup_selection : backup_selection.name => backup_selection
  }

  db_names = toset(flatten([
    for sel in local.backup_selection : sel.resources
  ]))
}
##################################################################
resource "aws_backup_vault" "rds_vault" {
  name = var.aws_backup_vault_name
}
##################################################################
resource "aws_backup_plan" "rds_plan" {
  for_each = local.backup_vault

  name = each.value.name

  rule {
    rule_name         = each.value.rule_name
    target_vault_name = each.value.target_vault_name
    schedule          = each.value.schedule
    start_window      = each.value.start_window
    completion_window = each.value.completion_window
    lifecycle {
      delete_after = each.value.delete_after
    }
  }

  depends_on = [aws_backup_vault.rds_vault]
}
##################################################################
data "aws_db_instance" "main" {
  for_each = local.db_names

  db_instance_identifier = each.key
}
##################################################################
resource "aws_backup_selection" "rds_selection" {
  for_each = local.backup_selection

  iam_role_arn = aws_iam_role.backup_role.arn
  name         = each.value.name
  plan_id      = aws_backup_plan.rds_plan[each.value.backup_plan_id].id

  resources = [
    for backup_resource in each.value.resources :
    data.aws_db_instance.main[backup_resource].db_instance_arn
  ]
}
##################################################################