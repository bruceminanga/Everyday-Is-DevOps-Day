provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}

resource "aws_sqs_queue" "test" {
  name                      = "drift-queue"
  delay_seconds             = 0
}