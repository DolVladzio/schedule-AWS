##################################################################
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../modules/cloudflare_dns"
}

locals {
  config = jsondecode(file("cloudflare_dns.json"))
}
##################################################################
dependencies {
  paths = ["../network"]
}
##################################################################
dependency "network" {
  config_path = "../network"

  mock_outputs = {
    nat_eip_ip_list = {}
  }

  mock_outputs_merge_strategy_with_state = "deep_map_only"
}
##################################################################
inputs = merge(
  {
    aws_region           = local.config.aws_region
    dns_records_config   = local.config.dns_records_config
    cloudflare_api_token = get_env("CLOUDFLARE_API_TOKEN")
    cloudflare_zone_id   = get_env("CLOUDFLARE_ZONE_ID")
  },
  dependency.network.outputs
)
##################################################################