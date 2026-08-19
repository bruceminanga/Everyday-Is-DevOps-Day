# 1. S3 Storage Bucket
resource "aws_s3_bucket" "app_media" {
  bucket = var.bucket_name

  tags = {
    Name        = "${var.environment}-django-media-storage"
    Environment = var.environment
  }
}

# 2. Security Group Firewall
resource "aws_security_group" "app_firewall" {
  name        = "${var.environment}-app-firewall"
  description = "Allow traffic for React and Django"
  vpc_id      = var.vpc_id

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

  tags = {
    Environment = var.environment
  }
}

# 3. EC2 Server
resource "aws_instance" "app_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.app_firewall.id]
  user_data_replace_on_change = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y docker.io
              systemctl start docker

              docker run -d -p 80:80 ${var.frontend_image}
              docker run -d -p 8000:8000 ${var.backend_image}
              EOF

  tags = {
    Name        = "${var.environment}-fullstack-server"
    Environment = var.environment
  }
}
