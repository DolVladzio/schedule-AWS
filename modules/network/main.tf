##################################################################
locals {
  vpcs_map = { for vpc in var.vpc : vpc.name => vpc }

  subnets = merge([
    for vpc_key, vpc in local.vpcs_map : {
      for subnet in vpc.subnets :
      "${subnet.name}" => {
        name              = subnet.name
        vpc_id            = vpc_key
        cidr_block        = subnet.cidr_block
        availability_zone = "${var.aws_region}${subnet.zone}"
        public         = subnet.public
      }
    }
  ]...)
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
resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main-vpc[each.value.vpc_id].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public

  tags = {
    Name = each.value.name
  }
}
##################################################################