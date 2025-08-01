##################################################################
locals {
  vpcs = { for vpc in var.vpc : vpc.name => vpc }

  subnets = merge([
    for vpc_key, vpc in local.vpcs : {
      for subnet in vpc.subnets :
      "${subnet.name}" => {
        name              = subnet.name
        vpc_id            = vpc_key
        cidr_block        = subnet.cidr_block
        availability_zone = "${var.aws_region}${subnet.zone}"
        public            = subnet.public
      }
    }
  ]...)
  # Determine if a VPC has private subnets
  vpc_has_private_subnets = {
    for vpc_key, vpc in local.vpcs :
    vpc_key => length([for subnet in vpc.subnets : subnet if !subnet.public]) > 0
  }
  # Determine if a VPC has public subnets
  vpc_has_public_subnets = {
    for vpc_key, vpc in local.vpcs :
    vpc_key => length([for subnet in vpc.subnets : subnet if subnet.public]) > 0
  }

  public_subnets      = { for k, sn in local.subnets : k => sn if sn.public }
  private_subnets     = { for k, sn in local.subnets : k => sn if !sn.public }
  first_public_subnet = keys(local.public_subnets)[0]
}
##################################################################
resource "aws_vpc" "main-vpc" {
  for_each = local.vpcs

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
resource "aws_internet_gateway" "gw" {
  for_each = local.vpcs

  vpc_id = aws_vpc.main-vpc[each.key].id

  tags = {
    Name = "${each.value.name}-igw"
  }
}
##################################################################
resource "aws_eip" "nat" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
  tags = {
    Name = "${each.value.name}-eip"
  }
}
##################################################################
resource "aws_nat_gateway" "nt" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnets[local.first_public_subnet].id
  depends_on    = [aws_internet_gateway.gw]
  tags = {
    Name = "${each.value.name}-nat-gateway"
  }
}
##################################################################