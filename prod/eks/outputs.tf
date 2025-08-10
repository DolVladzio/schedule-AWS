##################################################################
output "clusters" {
  value       = {
	for cluster, info in aws_eks_cluster.main : cluster => {
		access_config = info.access_config
		version = info.version
		subnet_ids = info.vpc_config[0].subnet_ids
	}
  }
}
##################################################################
output "node_group" {
  value       = {
	for cluster, node in aws_eks_node_group.main : cluster => {
		cluster_name = node.cluster_name
		subnet_ids = node.subnet_ids
		scaling_config = node.scaling_config
	}
  }
}
##################################################################
output "eks_access_entry" {
  value       = {
	for user, cluster in aws_eks_access_entry.main : user => {
		cluster_name = cluster.cluster_name
		principal_arn = cluster.principal_arn
	}
  }
}
##################################################################