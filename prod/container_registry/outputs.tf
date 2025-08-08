##################################################################
output "ecr" {
  description = "Map of ECR and their info"
  value = { for k, ecr in aws_ecr_repository.docker_repo : k => {
    name           = ecr.name
    repository_url = ecr.repository_url
    }
  }
}
##################################################################