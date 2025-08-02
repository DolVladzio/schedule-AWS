##################################################################
include "root" {
	path = find_in_parent_folders("root.hcl")
}

terraform {
	source = "../../modules/vm"
}

locals {
  config = jsondecode(file("vm.json"))
}
##################################################################
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    subnets = {}
    security_groups = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
inputs = merge(
  {
    aws_region           = local.config.aws_region
    vm_instances   		 = local.config.vm_instances
	ssh_keys			 = local.config.ssh_keys
  },
  dependency.network.outputs
)
##################################################################
