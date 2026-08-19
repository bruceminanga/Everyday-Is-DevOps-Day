# 1. Create the Virtual Private Cloud (VPC)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# 2. Create the Public Subnet inside that VPC
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id # <-- Connects subnet to our VPC above
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
  }
}
