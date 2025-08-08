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
dependencies {
  paths = ["../network"]
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
    aws_region     = local.config.aws_region
    db_instances   = local.config.db_instances
    secret_manager = local.config.secret_manager
  },
  dependency.network.outputs
)
##################################################################