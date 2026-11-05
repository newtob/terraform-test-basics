# This repo is never deployed. The skip_* flags let `terraform validate` and
# `terraform plan` run without AWS credentials; tests use a mocked provider.
provider "aws" {
  region = var.aws_region

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}
