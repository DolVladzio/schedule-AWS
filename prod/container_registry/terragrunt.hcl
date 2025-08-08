##################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/container_registry"
}

locals {
  config = jsondecode(file("container_registry.json"))
}
##################################################################
dependencies {
  paths = ["../network"]
}
##################################################################
inputs = {
  aws_region         = local.config.aws_region
  aws_ecr_repository = local.config.aws_ecr_repository
}
##################################################################