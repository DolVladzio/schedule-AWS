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

  tags = { Name = each.value.name }
}
##################################################################
resource "aws_subnet" "subnets" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.main-vpc[each.value.vpc_id].id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = each.value.public

  tags = { Name = each.value.name }
}
##################################################################
resource "aws_internet_gateway" "gw" {
  for_each = local.vpcs

  vpc_id = aws_vpc.main-vpc[each.key].id

  tags = { Name = "${each.value.name}-igw" }
}
##################################################################
resource "aws_eip" "nat" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  domain = each.value.eip_domain

  depends_on = [aws_internet_gateway.gw]

  tags = { Name = "${each.value.name}-eip" }
}
##################################################################
resource "aws_nat_gateway" "nt" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.subnets[local.first_public_subnet].id
  depends_on    = [aws_internet_gateway.gw]

  tags = { Name = "${each.value.name}-nat-gateway" }
}
##################################################################
resource "aws_route_table" "public" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_public_subnets[k] }

  vpc_id = aws_vpc.main-vpc[each.key].id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw[each.key].id
  }

  tags = { Name = "${each.value.name}-public-rt" }
}
##################################################################
resource "aws_route_table_association" "public" {
  for_each = local.public_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.public[each.value.vpc_id].id
}
##################################################################
resource "aws_route_table" "private" {
  for_each = { for k, v in local.vpcs : k => v if local.vpc_has_private_subnets[k] }

  vpc_id = aws_vpc.main-vpc[each.key].id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nt[each.key].id
  }

  tags = { Name = "${each.value.name}-private-rt" }
}
##################################################################
resource "aws_route_table_association" "private" {
  for_each = local.private_subnets

  subnet_id      = aws_subnet.subnets[each.key].id
  route_table_id = aws_route_table.private[each.value.vpc_id].id
}
##################################################################
resource "aws_security_group" "all" {
  for_each = { for sg in var.security_groups : sg.name => sg }

  name        = each.value.name
  description = each.value.description
  vpc_id      = aws_vpc.main-vpc[each.value.vpc_name].id

  tags = { Name = "${each.value.name}" }
}
##################################################################
resource "aws_vpc_security_group_ingress_rule" "all" {
  for_each = {
    for item in flatten([
      for sg in var.security_groups : [
        for rule in sg.ingress :
        {
          sg_name   = sg.name
          protocol  = rule.protocol
          port      = rule.port
          attach_to = rule.attach_to
        }
      ]
    ]) : "${item.sg_name}-${item.attach_to}" => item
  }

  lifecycle {
    create_before_destroy = true
  }

  security_group_id = aws_security_group.all[each.value.sg_name].id
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = each.value.protocol

  referenced_security_group_id = aws_security_group.all[each.value.sg_name].id
}
##################################################################
resource "aws_vpc_security_group_egress_rule" "all" {
  for_each = {
    for item in flatten([
      for sg in var.security_groups : [
        for rule in sg.egress :
        {
          sg_name     = sg.name
          protocol    = rule.protocol
          port        = rule.port
          destination = rule.destination
        }
      ]
    ]) : "${item.sg_name}-${item.destination}-${item.port}-${item.protocol}" => item
  }

  lifecycle {
    create_before_destroy = true
  }

  security_group_id = aws_security_group.all[each.value.sg_name].id
  from_port         = each.value.port
  to_port           = each.value.port
  ip_protocol       = each.value.protocol

  referenced_security_group_id = aws_security_group.all[each.value.sg_name].id
}
##################################################################