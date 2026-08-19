output "vpc_id" {
  description = "The ID of the custom VPC"
  value       = module.networking.vpc_id
}

output "server_public_ip" {
  description = "Public IP where React & Django are accessible"
  value       = module.compute.server_public_ip
}

output "media_bucket_name" {
  description = "S3 bucket for Django media uploads"
  value       = module.compute.media_bucket_name
}
