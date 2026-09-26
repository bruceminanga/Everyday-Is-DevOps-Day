terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "downloading_game_iso" {
  name         = "ghcr.io/daocloud/dao-2048:v1.4.1"
  keep_locally = true
}

resource "docker_container" "run_game_image" {
  image = docker_image.downloading_game_iso.image_id
  name  = "relax-and-play"
  ports {
    internal = 80
    external = 8080
  }
}

output "play_here" {
  value = "Open your browser to: http://localhost:8080"
}