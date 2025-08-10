##################################################################
locals {
  cluster = {
    for cluster in var.eks_cluster : cluster.name => cluster
  }

  node = {
    for node in var.eks_node_group : node.node_group_name => node
  }

  eks_access_entry = {
    for user in var.eks_access_entry : user.user_name => user
  }
}
##################################################################
data "aws_iam_role" "eks_cluster_role" {
  name = var.eks_cluster_role_arn
}
##################################################################
data "aws_iam_role" "eks_node_role" {
  name = var.eks_cluster_node_role_arn
}
##################################################################
resource "aws_eks_cluster" "main" {
  for_each = local.cluster

  name = each.value.name

  access_config {
    authentication_mode = each.value.authentication_mode
  }

  role_arn = data.aws_iam_role.eks_cluster_role.arn
  version  = each.value.version

  vpc_config {
    subnet_ids = [
      for subnet in each.value.subnet_ids : var.subnets[subnet].id
    ]
  }

  depends_on = [
    data.aws_iam_role.eks_cluster_role,
    data.aws_iam_role.eks_node_role
  ]
}
##################################################################
resource "aws_eks_node_group" "main" {
  for_each = local.node

  cluster_name    = each.value.cluster_name
  node_group_name = each.value.node_group_name
  node_role_arn   = data.aws_iam_role.eks_node_role.arn
  subnet_ids = [
    for subnet in each.value.subnet_ids : var.subnets[subnet].id
  ]

  scaling_config {
    desired_size = each.value.scaling_config.desired_size
    max_size     = each.value.scaling_config.max_size
    min_size     = each.value.scaling_config.min_size
  }

  update_config {
    max_unavailable = each.value.update_config.max_unavailable
  }

  depends_on = [aws_eks_cluster.main]
}
##################################################################
resource "aws_eks_access_entry" "main" {
  for_each = local.eks_access_entry

  cluster_name  = each.value.cluster_name
  principal_arn = var.iam_users[each.value.user_name]

  depends_on = [
    "aws_eks_cluster.main",
    "aws_eks_node_group.main"
  ]
}
##################################################################