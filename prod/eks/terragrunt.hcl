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
dependencies {
  paths = ["../network"]
}
##################################################################
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    subnets         = {}
    security_groups = {}
    iam_users       = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
dependency "iam_users" {
  config_path = "../iam_role"

  mock_outputs = {
    iam_users = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
inputs = merge(
  {
    aws_region                = local.config.aws_region
    eks_cluster_role_arn      = local.config.eks_cluster_role_arn
    eks_cluster_node_role_arn = local.config.eks_cluster_node_role_arn
    eks_cluster               = local.config.eks_cluster
    eks_node_group            = local.config.eks_node_group
    eks_access_entry          = local.config.eks_access_entry
  },
  dependency.network.outputs,
  dependency.iam_users.outputs
)
##################################################################