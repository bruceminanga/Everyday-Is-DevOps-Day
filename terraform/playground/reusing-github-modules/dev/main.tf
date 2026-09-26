locals {
  environment = "dev"
}

# ==============================================================================
# 1. Network Layer
# ==============================================================================
module "vpc" {
  source = "github.com/bruceminanga/m-treat-project//terraform/modules/vpc?ref=main"

  environment           = local.environment
  enable_nat_gateway    = true
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_a_cidr  = "10.0.1.0/24"
  public_subnet_b_cidr  = "10.0.2.0/24"
  private_subnet_a_cidr = "10.0.10.0/24"
  private_subnet_b_cidr = "10.0.20.0/24"
}

# ==============================================================================
# 2. Storage Layer
# ==============================================================================
module "s3" {
  source = "github.com/bruceminanga/m-treat-project//terraform/modules/s3-secure-bucket?ref=main"

  environment = local.environment
  bucket_name = "my-app-media-storage-${local.environment}"
}

# ==============================================================================
# 3. Compute Layer
# ==============================================================================
module "ec2" {
  source = "github.com/bruceminanga/m-treat-project//terraform/modules/ec2-app-server?ref=main"

  environment   = local.environment
  vpc_id        = module.vpc.vpc_id
  subnet_id     = module.vpc.public_subnet_a_id
  s3_bucket_arn = module.s3.bucket_arn

  instance_type = "t3.micro"
}

# ==============================================================================
# 4. The Load Balancer (The Reception Desk)
# ==============================================================================
variable "enable_alb" {
  type        = bool
  default     = false # Keep false for free LocalStack, set to true for real AWS!
  description = "Toggle to create the Application Load Balancer"
}

module "alb" {
  count  = var.enable_alb ? 1 : 0
  source = "github.com/bruceminanga/m-treat-project//terraform/modules/alb?ref=main"

  environment        = local.environment
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  target_instance_id = module.ec2.instance_id
  app_port           = 80
}