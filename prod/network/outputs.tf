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
output "nat_eip_ip_list" {
  value = [for eip in aws_eip.nat : eip.public_ip]
}
##################################################################