##################################################################
locals {
  records = [
    for record in var.dns_records_config : {
      name    = record.name
      type    = record.type
      value   = var.nat_eip_ip_list[record.value].ip
      proxied = lookup(record, "proxied", true)
      ttl     = lookup(record, "ttl", 1)
      zone_id = var.cloudflare_zone_id
    }
  ]
}
##################################################################
resource "cloudflare_dns_record" "dns" {
  for_each = {
    for rec in local.records : rec.name => rec
  }

  zone_id = each.value.zone_id
  name    = each.value.name
  type    = each.value.type
  content = each.value.value
  ttl     = each.value.ttl
  proxied = each.value.proxied
}
##################################################################