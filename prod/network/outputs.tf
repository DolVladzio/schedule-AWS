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
# EIP ip list for a view
output "nat_eip_ip_list" {
  value = [for eip in aws_eip.nat : eip.public_ip]
}
##################################################################
output "security_groups" {
  value = [
    for sg in aws_security_group.all : {
      name = sg.name
      id = sg.id
    }
  ]
}
##################################################################