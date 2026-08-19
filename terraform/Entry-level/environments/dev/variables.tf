variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_cidr" {
  type = string
}

variable "subnet_cidr" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "bucket_name" {
  type = string
}

variable "frontend_image" {
  type = string
}

variable "backend_image" {
  type = string
}
