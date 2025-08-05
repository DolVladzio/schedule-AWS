##################################################################
locals {
  db = { for db in var.db_instances : db.name => db }

  db_credentials = {
    for instance_name, config in local.db :
    instance_name => jsondecode(data.aws_secretsmanager_secret_version.rds_credentials[instance_name].secret_string)
  }
}
##################################################################
resource "aws_secretsmanager_secret" "rds_credentials" {
  for_each = local.db
  
  name = each.value.aws_secrets_manager_name
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  for_each = local.db

  secret_id     = aws_secretsmanager_secret.rds_credentials[each.key].id
  secret_string = jsonencode({
    username = each.value.username
    password = each.value.password
  })
}

data "aws_secretsmanager_secret_version" "rds_credentials" {
  for_each = local.db

  secret_id = aws_secretsmanager_secret.rds_credentials[each.key].id

  depends_on = [ aws_secretsmanager_secret_version.rds_credentials_version ]
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
  username = local.db_credentials[each.key].username
  password = local.db_credentials[each.key].password
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