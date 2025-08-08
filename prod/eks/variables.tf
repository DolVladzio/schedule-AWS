##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "security_groups" {
  type = map(string)
}
##################################################################
variable "subnets" {
  type = map(object({
    id   = string
    zone = string
  }))
}
##################################################################
variable "eks_cluster_role_arn" {}
##################################################################
variable "eks_cluster_node_role_arn" {}
##################################################################
variable "eks_cluster" {
  type = list(object({
    name                = string
    version             = string
    authentication_mode = string
    subnet_ids          = list(string)
  }))
}
##################################################################
variable "eks_node_group" {
  type = list(object({
    cluster_name    = string
    node_group_name = string
    subnet_ids      = list(string)
    scaling_config = object({
      desired_size = number
      max_size     = number
      min_size     = number
    })
    update_config = object({
      max_unavailable = number
    })
    instance_types = list(string)
  }))
}
##################################################################
variable "eks_access_entry" {
  type = map(object({
    cluster_name  = string
    principal_arn = string
  }))
}
##################################################################