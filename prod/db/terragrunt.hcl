##################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/db"
}

locals {
  config = jsondecode(file("db.json"))
}
##################################################################
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    subnets         = {}
    security_groups = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
inputs = merge(
  {
    aws_region            = local.config.aws_region
    db_instances          = local.config.db_instances
    secret_manager        = local.config.secret_manager
    aws_backup_vault_name = local.config.aws_backup_vault_name
    aws_backup_plan       = local.config.aws_backup_plan
    aws_backup_selection  = local.config.aws_backup_selection
  },
  dependency.network.outputs
)
##################################################################