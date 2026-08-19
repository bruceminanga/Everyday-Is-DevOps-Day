output "server_public_ip" {
  description = "Public IP of the server"
  value       = aws_instance.app_server.public_ip
}

output "media_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.app_media.bucket
}
