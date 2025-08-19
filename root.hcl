remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket  = get_env("BUCKET_NAME")
    region  = get_env("AWS_REGION")
    key     = "${path_relative_to_include()}/terraform.tfstate"
    encrypt = true
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
	provider "aws" {
		region  = "$${var.aws_region}"
	}

##################################################################
terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }
}
##################################################################
provider "cloudflare" {
  api_token = "$${var.cloudflare_api_token}"
}
##################################################################
EOF
}
##################################################################
inputs = {
  aws_region = get_env("AWS_REGION")
}
##################################################################