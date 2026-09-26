terraform {
  required_providers {
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

# Fetch a live cat fact from an open API
data "http" "cat_fact" {
  url = "https://catfact.ninja/fact"
}

# Generate a silly pet companion
resource "random_pet" "companion" {
  length    = 2
  separator = " the "
}

output "cheer_up_message" {
  value = <<EOT

🐾 Meet your new emotional support familiar:
   -> ${upper(random_pet.companion.id)}

🐱 Cat fact of the day:
   -> "${jsondecode(data.http.cat_fact.response_body).fact}"
EOT
}