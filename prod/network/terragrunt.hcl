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
  vpc             = local.config.vpc
  network_acl     = local.config.network_acl
  security_groups = local.config.security_groups
  aws_region      = local.config.aws_region
}
##################################################################