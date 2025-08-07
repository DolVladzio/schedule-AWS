##################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/backup"
}

locals {
  config = jsondecode(file("backup.json"))
}
##################################################################
inputs = {
  aws_region            = local.config.aws_region
  aws_backup_vault_name = local.config.aws_backup_vault_name
  aws_backup_plan       = local.config.aws_backup_plan
  aws_backup_selection  = local.config.aws_backup_selection
}
##################################################################