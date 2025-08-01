##################################################################
locals {
  vpcs_map = { for vpc in var.vpc : vpc.name => vpc }
}
##################################################################
resource "aws_vpc" "main-vpc" {
  for_each = local.vpcs_map

  cidr_block = each.value.vpc_cidr_block
  tags = {
    Name = each.value.name
  }
}
##################################################################