terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider block targeting Real AWS
provider "aws" {
  region = "us-east-1"
}

# Real SSM Parameter in AWS Systems Manager
resource "aws_ssm_parameter" "my_secret" {
  name        = "/myapp/secret_key"
  description = "App secret stored in Parameter Store"
  type        = "SecureString"  # Best practice: Encrypts the secret at rest in real AWS
  value       = "NEWsecret456"
}

# Output to confirm creation
output "ssm_parameter_arn" {
  value       = aws_ssm_parameter.my_secret.arn
  description = "The ARN of the real SSM parameter in AWS"
}