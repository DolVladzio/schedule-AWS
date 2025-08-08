##################################################################
locals {
  ecr = {
    for ecr in var.aws_ecr_repository : ecr.name => ecr
  }
}
##################################################################
resource "aws_ecr_repository" "docker_repo" {
  for_each = local.ecr

  name = each.value.name

  image_scanning_configuration {
    scan_on_push = each.value.image_scanning_configuration.scan_on_push
  }

  image_tag_mutability = each.value.image_tag_mutability
  force_delete         = each.value.force_delete

  encryption_configuration {
    encryption_type = each.value.encryption_configuration.encryption_type
  }

  tags = { Name = each.value.tags }
}
##################################################################