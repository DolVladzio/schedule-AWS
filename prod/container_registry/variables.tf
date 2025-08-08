##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "aws_ecr_repository" {
  type = map(object({
    name                 = string
    image_tag_mutability = string
    image_scanning_configuration = object({
      scan_on_push = string
    })
    encryption_configuration = object({
      encryption_type = string
    })
    tags = string
  }))
}
##################################################################