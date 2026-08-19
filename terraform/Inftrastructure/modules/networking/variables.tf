variable "vpc_cidr" {
  description = "The IP range for the VPC (e.g., 10.0.0.0/16)"
  type        = string
}

variable "subnet_cidr" {
  description = "The IP range for the public subnet (e.g., 10.0.1.0/24)"
  type        = string
}

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}
