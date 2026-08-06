terraform {
  required_version = "~> 1.11" # Allows >= 1.11.0 and < 2.0.0

  backend "s3" {
    bucket       = "my-company-tf-state-prod"
    key          = "core-infrastructure/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # Native S3 locking supported in Terraform 1.10+
  }
}