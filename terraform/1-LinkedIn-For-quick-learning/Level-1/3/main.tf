provider "local" {}

resource "local_file" "renamed_file" {
  filename = "${path.module}/my_password.txt"
  content  = "SuperSecretPassword123!"
} 