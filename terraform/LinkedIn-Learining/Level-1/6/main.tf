terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

resource "local_file" "my_first_resource" {
  content  = var.file_content
  filename = "${path.module}/hello_world.txt"
}
