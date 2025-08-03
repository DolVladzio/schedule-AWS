##################################################################
variable "aws_region" {
  type        = string
  description = "AWS region for the provider"
}
##################################################################
variable "cloudflare_api_token" {}
##################################################################
variable "cloudflare_zone_id" {}
##################################################################
variable "dns_records_config" {
  description = "DNS records from config"
  type = list(object({
    name    = string
    type    = string
    proxied = bool
    value   = string
  }))
}
##################################################################
variable "nat_eip_ip_list" {
  type = map(object({
    id = string
    ip = string
  }))
}
##################################################################
variable "security_groups" {
  type = map(string)
}
##################################################################