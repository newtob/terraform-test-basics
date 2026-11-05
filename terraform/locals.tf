locals {
  tags = merge(
    {
      Project   = "terraform-test-basics"
      ManagedBy = "terraform"
    },
    var.tags,
  )
}
