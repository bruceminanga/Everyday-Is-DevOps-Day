terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 2. THE PROVIDER BLOCK
provider "aws" {
  region = "us-east-1"
}

# 3. LOOK UP A CURRENT AMI DYNAMICALLY
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# 4. A SECURITY GROUP SO YOU CAN ACTUALLY REACH THE INSTANCE
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound SSH"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Fixed invalid placeholder address
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 5. THE RESOURCE BLOCK
resource "aws_instance" "my_first_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_ssh.id]

  tags = {
    Name = "MyFirstTerraformInstance"
  }
}

# 6. OUTPUT
output "instance_public_ip" {
  value = aws_instance.my_first_server.public_ip
}