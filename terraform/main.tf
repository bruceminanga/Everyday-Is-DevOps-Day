provider "aws" {
  region = "us-east-1"
}

# paid localstack feature Example: Local ECR Repository for your Docker image 
# Use kubernetes instead
# resource "aws_ecr_repository" "my_app_repo" {
#  name = "my-local-app"
# }

# Free LocalStack service: S3 Bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-learning-bucket"
}