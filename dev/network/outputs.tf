##################################################################
output "subnets" {
  description = "Map of subnet keys to their IDs and attributes"
  value = { for k, subnet in aws_subnet.subnets : k => {
    id   = subnet.id
    zone = subnet.availability_zone
    }
  }
}
##################################################################
# EIP ip list for a review
output "nat_eip_ip_list" {
  value = {
    for name, ip in aws_eip.nat :
    "${replace(name, "-", "_")}_eip" => {
      id = ip.id
      ip = ip.public_ip
    }
  }
}
##################################################################
output "security_groups" {
  value = {
    for name, sg in aws_security_group.all : name => sg.id
  }
}
##################################################################