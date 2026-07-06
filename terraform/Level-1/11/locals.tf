locals {
  # 1. Standardizing a naming prefix
  prefix = "acmecorp-billing-${var.env}"

  # 2. Creating a standardized, reusable map for tags
  common_tags = {
    Environment = var.env
    Project     = "billing"
    Company     = "acmecorp"
    ManagedBy   = "terraform"
    # 3. Dynamic complex expression: timestamping when it was created
    CreatedAt = timestamp()
  }

  # 4. Data transformation: convert list to set for for_each
  bucket_names = toset(["logs", "backups", "artifacts"])
} 