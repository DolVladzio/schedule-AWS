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
    name            = string
    aws_backup_role = string
    backup_plan_id  = string
    resources       = list(string)
  }))
  description = "AWS backup selection"
}
##################################################################
variable "backup_role_arns" {
  type        = map(string)
  description = "description"
}
##################################################################