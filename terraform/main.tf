module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.3"

  bucket = var.bucket_name

  # The public access block is managed below (not by the module) because
  # `terraform test` can only read a module's outputs, not its inner resources.
  attach_public_policy = false

  versioning = {
    enabled = var.enable_versioning
  }

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = local.tags
}

# Block all public access to the bucket. Covered by tests/s3_bucket.tftest.hcl.
resource "aws_s3_bucket_public_access_block" "main" {
  bucket = module.s3_bucket.s3_bucket_id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
