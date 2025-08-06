##################################################################
locals {
  backup_vault = {
    for backup_vault in var.aws_backup_plan : backup_vault.name => backup_vault
  }

  backup_selection = {
    for backup_selection in var.aws_backup_selection : backup_selection.name => backup_selection
  }

  db = { for db in var.db_instances : db.name => db }

  secret_manager = {
    for secret in var.secret_manager : secret.name => secret
  }

  db_credentials = {
    for instance_name, config in local.secret_manager :
    instance_name => jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[instance_name].secret_string)
  }
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

  depends_on = [ aws_backup_vault.rds_vault ]
}
##################################################################
resource "aws_iam_role" "backup_role" {
  name = "aws-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "backup.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "backup_attach" {
  role       = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}
##################################################################
resource "aws_backup_selection" "rds_selection" {
  for_each = local.backup_selection

  iam_role_arn = aws_iam_role.backup_role.arn
  name         = each.value.name
  plan_id      = aws_backup_plan.rds_plan[each.value.backup_plan_id].id

  resources = [
    for backup_resource in each.value.resources :
    aws_db_instance.main[backup_resource].arn
  ]
}
##################################################################
resource "aws_secretsmanager_secret" "rds_credentials" {
  for_each = local.secret_manager

  name = each.value.name
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  for_each = local.secret_manager

  secret_id = aws_secretsmanager_secret.rds_credentials[each.key].id
  secret_string = jsonencode({
    username = each.value.username
    password = each.value.password
  })
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  for_each = local.secret_manager

  secret_id = aws_secretsmanager_secret.rds_credentials[each.key].id

  depends_on = [aws_secretsmanager_secret_version.rds_credentials_version]
}
##################################################################
resource "aws_db_subnet_group" "main" {
  for_each = local.db

  name = each.value.aws_db_subnet_group_name
  subnet_ids = [
    for subnets in each.value.subnet_group_name : var.subnets[subnets].id
  ]
  tags = { Name = each.value.tags["db-subnets"] }
}
##################################################################
resource "aws_db_instance" "main" {
  for_each = local.db

  identifier            = each.value.name
  engine                = each.value.engine
  engine_version        = each.value.engine_version
  instance_class        = each.value.instance_class
  allocated_storage     = each.value.allocated_storage
  max_allocated_storage = each.value.max_allocated_storage
  storage_type          = each.value.storage_type
  multi_az              = each.value.multi_az
  publicly_accessible   = each.value.publicly_accessible
  storage_encrypted     = each.value.storage_encrypted

  db_name  = each.value.db_name
  username = local.db_credentials[each.value.secret_manager_name].username
  password = local.db_credentials[each.value.secret_manager_name].password
  port     = each.value.port

  db_subnet_group_name = each.value.aws_db_subnet_group_name
  vpc_security_group_ids = [
    for sg in each.value.vpc_security_groups : var.security_groups[sg]
  ]

  backup_retention_period = each.value.backup_retention_period
  backup_window           = each.value.backup_window
  maintenance_window      = each.value.maintenance_window

  deletion_protection       = each.value.deletion_protection
  skip_final_snapshot       = each.value.skip_final_snapshot
  final_snapshot_identifier = each.value.final_snapshot_identifier

  monitoring_interval          = each.value.monitoring_interval
  performance_insights_enabled = each.value.performance_insights_enabled

  tags = { Name = each.value.tags["db"] }
}
##################################################################