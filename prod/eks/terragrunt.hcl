##################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/eks"
}

locals {
  config = jsondecode(file("eks.json"))
}
##################################################################
inputs = {
  aws_region      = local.config.aws_region
}
##################################################################