
# 1. Instantiate the Networking Base
module "networking" {
  source      = "../../modules/networking"
  vpc_cidr    = var.vpc_cidr
  subnet_cidr = var.subnet_cidr
  environment = var.environment
}

# 2. Instantiate the Compute Base (using outputs from Networking)
module "compute" {
  source         = "../../modules/compute"
  vpc_id         = module.networking.vpc_id
  subnet_id      = module.networking.subnet_id
  instance_type  = var.instance_type
  ami_id         = var.ami_id
  bucket_name    = var.bucket_name
  frontend_image = var.frontend_image
  backend_image  = var.backend_image
  environment    = var.environment
}
