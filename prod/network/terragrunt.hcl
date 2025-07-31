##################################################################
include "root" {
	path = find_in_parent_folders("root.hcl")
}

terraform {
	source = "../../modules/network"
}

locals {
  config = jsondecode(file("network.json"))
}
##################################################################
inputs = {
	vpc_name = local.config.name
	vpc_cidr_block = local.config.vpc_cidr_block
	aws_region = local.config.aws_region
}
##################################################################