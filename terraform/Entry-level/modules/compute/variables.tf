variable "vpc_id" {
  description = "VPC ID from the networking module"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID from the networking module"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
}

variable "ami_id" {
  description = "Operating system AMI ID"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 media bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "frontend_image" {
  description = "Docker image tag for React"
  type        = string
}

variable "backend_image" {
  description = "Docker image tag for Django"
  type        = string
}
