# Plan-only tests against a mocked AWS provider: no credentials, nothing is created.
# Tests can read root-module resources and the module's outputs, not its inner resources.

mock_provider "aws" {}

variables {
  bucket_name = "terraform-test-basics-example"
}

run "s3_bucket_is_not_public" {
  command = plan

  assert {
    condition     = aws_s3_bucket_public_access_block.main.block_public_acls == true
    error_message = "block_public_acls must be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.main.block_public_policy == true
    error_message = "block_public_policy must be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.main.ignore_public_acls == true
    error_message = "ignore_public_acls must be true."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.main.restrict_public_buckets == true
    error_message = "restrict_public_buckets must be true."
  }
}

run "no_bucket_policy_attached" {
  command = plan

  assert {
    condition     = module.s3_bucket.s3_bucket_policy == null
    error_message = "No bucket policy (which could grant public access) should be attached."
  }
}

run "versioning_and_tags" {
  command = plan

  assert {
    condition     = module.s3_bucket.aws_s3_bucket_versioning_status == "Enabled"
    error_message = "Versioning must be enabled by default."
  }

  assert {
    condition     = module.s3_bucket.s3_bucket_tags["ManagedBy"] == "terraform"
    error_message = "Bucket must carry the default ManagedBy tag."
  }
}

run "rejects_invalid_bucket_name" {
  command = plan

  variables {
    bucket_name = "Bad_Name"
  }

  expect_failures = [var.bucket_name]
}
