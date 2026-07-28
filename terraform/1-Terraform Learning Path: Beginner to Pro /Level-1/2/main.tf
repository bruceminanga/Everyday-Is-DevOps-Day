provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  endpoints {
    ssm = "http://localhost:4566"
  }
}

resource "aws_ssm_parameter" "my_secret" {
  name  = "/myapp/secret_key"
  type  = "String"
  value = "NEWsecret456"
}