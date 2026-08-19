output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.custom_vpc.id
}

output "subnet_id" {
  description = "The ID of the Public Subnet"
  value       = aws_subnet.custom_public_subnet.id
}
