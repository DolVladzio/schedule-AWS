##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "vpc" {
  type = list(object({
    name           = string
    vpc_cidr_block = string
    subnets = list(object({
      name       = string
      cidr_block = string
      public     = bool
      zone       = string
    }))
  }))
  description = "List of VPC configurations"
}
##################################################################