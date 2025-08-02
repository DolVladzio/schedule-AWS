##################################################################
# EIP ip list to pass into the module 'cloudflare_dns'
output "nat_eip_ip_list" {
  value = [for eip in aws_eip.nat : eip.public_ip]
}
##################################################################