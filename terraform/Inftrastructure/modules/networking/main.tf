# 1. Custom VPC
resource "aws_vpc" "custom_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-custom-vpc"
    Environment = var.environment
  }
}

# 2. Public Subnet
resource "aws_subnet" "custom_public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-public-subnet"
    Environment = var.environment
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}
