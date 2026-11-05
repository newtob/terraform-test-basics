variable "bucket_name" {
  description = "Globally unique name of the S3 bucket (3-63 chars, lowercase letters, digits and hyphens)."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "bucket_name must be 3-63 characters of lowercase letters, digits or hyphens, starting and ending with a letter or digit."
  }
}

variable "aws_region" {
  description = "AWS region for the provider. Only used for planning; nothing is deployed."
  type        = string
  default     = "eu-west-2"
  nullable    = false
}

variable "enable_versioning" {
  description = "Whether to enable object versioning on the bucket."
  type        = bool
  default     = true
  nullable    = false
}

variable "tags" {
  description = "Additional tags to apply to the bucket."
  type        = map(string)
  default     = {}
  nullable    = false
}
