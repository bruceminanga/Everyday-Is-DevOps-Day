provider "local" {}

resource "local_file" "secret_file" {
  filename = "${path.module}/my_password.txt"
  content  = "SuperSecretPassword123!"
} 