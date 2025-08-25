##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "vpc" {
  type = map(object({
    name           = string
    vpc_cidr_block = string
    eip_domain     = string
    eips           = list(string)
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
variable "network_acl" {
  type = map(object({
    vpc            = string
    public_subnets = list(string)
    ingress = list(object({
      rule_no    = number
      protocol   = string
      action     = string
      cidr_block = string
      from_port  = number
      to_port    = number
    }))
    egress = list(object({
      rule_no    = number
      protocol   = string
      action     = string
      cidr_block = string
      from_port  = number
      to_port    = number
    }))
  }))
}
##################################################################
variable "security_groups" {
  type = map(object({
    name        = string
    vpc_name    = string
    description = string
    attach_to   = string
    ingress = list(object({
      protocol = string
      port     = number
      source   = string
    }))
    egress = list(object({
      protocol    = string
      port        = number
      destination = string
    }))
  }))
  description = "List of security group configurations"
}
##################################################################