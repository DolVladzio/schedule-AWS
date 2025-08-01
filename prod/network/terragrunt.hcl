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
	vpc = local.config.vpc
	aws_region = local.config.aws_region
}
##################################################################