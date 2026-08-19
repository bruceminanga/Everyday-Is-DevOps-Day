# ==============================================================================
# STEP 0: PROVIDER & SETUP
# ==============================================================================
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "test"
  secret_key                  = "test"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Only specify the endpoints you ACTUALLY use
  endpoints {
    ec2 = "http://localhost:4566"
    s3  = "http://localhost:4566"
  }
}

# ==============================================================================
# STEP 1: CORE NETWORKING (Custom VPC & Subnet)
# ==============================================================================

# 1. Custom VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev-custom-vpc"
  }
}

# 2. Public Subnet inside our VPC
resource "aws_subnet" "custom_public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id # <-- Links to VPC
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "dev-public-subnet"
  }
}

# 3. Internet Gateway (lets traffic in/out of the VPC)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom_vpc.id
}

# ==============================================================================
# STEP 2: STORAGE (S3 Media Bucket)
# ==============================================================================
resource "aws_s3_bucket" "app_media" {
  bucket = "my-django-media-uploads-bucket"

  tags = {
    Name = "django-media-storage"
  }
}

# ==============================================================================
# STEP 3: SECURITY & FIREWALL (Attached to our Custom VPC from Step 1)
# ==============================================================================
resource "aws_security_group" "app_firewall" {
  name        = "app-firewall"
  description = "Allow traffic for React and Django"
  vpc_id      = aws_vpc.custom_vpc.id # <-- Explicitly attached to Step 1 VPC!

  ingress {
    description = "React Frontend"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Django Backend API"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ==============================================================================
# STEP 4: COMPUTE (Placed inside our Subnet from Step 1) uploading my code to the server
# ==============================================================================
resource "aws_instance" "app_server" {
  ami                    = "ami-df5de72dee"                     # -> Just a blank Ubuntu OS
  instance_type          = "t3.micro"                           # -> Just the CPU & RAM size (1GB RAM)
  subnet_id              = aws_subnet.custom_public_subnet.id   # -> Where to plug the network cable
  vpc_security_group_ids = [aws_security_group.app_firewall.id] # -> The firewall rules

  # ============================================================================
  # THIS IS WHAT ACTUALLY BRINGS YOUR CODE TO THE SERVER:
  # ============================================================================

  # Tell Terraform: If I edit the script, build a fresh new server!
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              # 1. Install Docker on the blank Ubuntu OS
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker

              # 2. Pull YOUR images from Docker Hub and start them!
              # docker run -d -p 80:80 your-dockerhub-username/my-react-app:latest
              # docker run -d -p 8000:8000 your-dockerhub-username/my-django-app:latest

              # or run your local image directly
              docker run -d -p 80:80 everyday-is-devops-day-frontend:sha-a123
              docker run -d -p 8000:8000 everyday-is-devops-day-backend:sha-a123
              EOF

  tags = {
    Name = "fullstack-react-django-server" # -> Just a text label / name tag
  }
}

# ==============================================================================
# STEP 5: OUTPUTS what i want to see on the screen
# ==============================================================================
output "vpc_id" {
  description = "The ID of our custom VPC"
  value       = aws_vpc.custom_vpc.id
}

output "server_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "media_bucket_name" {
  description = "S3 bucket for Django media uploads"
  value       = aws_s3_bucket.app_media.bucket
}
