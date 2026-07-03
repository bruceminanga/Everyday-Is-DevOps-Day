terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.4.0"
    }
  }
}

resource "local_file" "my_server" {
  filename = "${path.module}/server_config.txt"
  content  = "Server is running perfectly."
} 