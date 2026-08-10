resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-company-prod-terraform-state"

  # Prevent accidental deletion of the bucket itself
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "state_lifecycle" {
  # CORRECTED LINE BELOW:
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "my-lifecycle-rule"
    status = "Enabled"

    # Add a filter with a target prefix
    filter {
      prefix = "logs/"
    }

    expiration {
      days = 30
    }
  }
}
