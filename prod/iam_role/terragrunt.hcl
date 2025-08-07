##################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/iam_role"
}

locals {
  config = jsondecode(file("iam_role.json"))
}
##################################################################
inputs = {
  aws_region                 = local.config.aws_region
  iam_role                   = local.config.iam_role
  iam_role_policy_attachment = local.config.iam_role_policy_attachment
}
##################################################################