##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "vpc" {
  type = list(object({
    name            = string
    vpc_cidr_block  = string
  }))
  description = "List of VPC configurations"
}
##################################################################