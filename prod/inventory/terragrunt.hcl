##################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/inventory"
}

locals {
  config = jsondecode(file("inventory.json"))
}
##################################################################
dependencies {
  paths = ["../network", "../db", "../vm"]
}
##################################################################
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    nat_eip_ip_list = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
dependency "vm" {
  config_path = "../vm"

  mock_outputs = {
    vms = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
dependency "db" {
  config_path = "../db"

  mock_outputs = {
    db = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
inputs = merge(
  {
    aws_region         = local.config.aws_region
    vms_config         = local.config.vms_config
    inventory_tpl_path = "${get_repo_root()}/inventory.tpl"
    inventory_ini_path = "${get_repo_root()}/ansible/inventory/inventory.ini"
  },
  dependency.network.outputs,
  dependency.vm.outputs,
  dependency.db.outputs
)
##################################################################
