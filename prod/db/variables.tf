##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "aws_backup_vault_name" {
  type        = string
  description = "AWS backup value's name"
}
##################################################################
variable "aws_backup_plan" {
  type = list(object({
    name              = string
    rule_name         = string
    target_vault_name = string
    schedule          = string
    start_window      = number
    completion_window = number
    delete_after      = number
  }))
  description = "AWS backup value's name"
}
##################################################################
variable "aws_backup_selection" {
  type = list(object({
    name           = string
    backup_plan_id = string
    resources      = list(string)
  }))
  description = "AWS backup selection"
}
##################################################################
variable "secret_manager" {
  type = list(object({
    name     = string
    username = string
    password = string
  }))
}
##################################################################
variable "db_instances" {
  type = list(object({
    name                  = string
    engine                = string
    engine_version        = string
    instance_class        = string
    allocated_storage     = number
    max_allocated_storage = number
    storage_type          = string
    multi_az              = bool
    publicly_accessible   = bool
    storage_encrypted     = bool

    db_name             = string
    port                = number
    secret_manager_name = string

    aws_db_subnet_group_name = string
    subnet_group_name        = list(string)
    vpc_security_groups      = list(string)

    backup_retention_period      = string
    backup_window                = string
    maintenance_window           = string
    deletion_protection          = bool
    skip_final_snapshot          = bool
    final_snapshot_identifier    = string
    monitoring_interval          = number
    performance_insights_enabled = bool

    tags = map(string)
  }))

  description = "List of VM instances to create with detailed configuration"
}
##################################################################
variable "security_groups" {
  type = map(string)
}
##################################################################
variable "subnets" {
  type = map(object({
    id   = string
    zone = string
  }))
}
##################################################################