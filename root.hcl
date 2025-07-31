remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
	bucket = "schedule-state-bucket"
	region  = "eu-central-1"
    key = "${path_relative_to_include()}/terraform.tfstate"
	encrypt = true
  }
}

generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
	provider "aws" {
		region  = "eu-central-1"
	}
EOF
}