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
dependencies {
  paths = ["../db"]
}
##################################################################
dependency "iam_role" {
  config_path = "../iam_role"

  mock_outputs = {
    backup_role_arns = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
inputs = merge(
  {
    aws_region            = local.config.aws_region
    aws_backup_vault_name = local.config.aws_backup_vault_name
    aws_backup_plan       = local.config.aws_backup_plan
    aws_backup_selection  = local.config.aws_backup_selection
  },
  dependency.iam_role.outputs
)
##################################################################