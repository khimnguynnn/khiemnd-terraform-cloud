locals {
  common_tags = {
    Owner       = "khiemnd"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "core-banking"
  }
}

data "aws_availability_zones" "available" { state = "available" }


module "vpc" {
  source = "git::https://github.com/khimnguynnn/khiemnd-terraform-cloud.git//modules/vpc"

  cidr_block           = var.cidr_block
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = data.aws_availability_zones.available.names
  tags                 = local.common_tags
}

module "ecs" {
  source = "git::https://github.com/khimnguynnn/khiemnd-terraform-cloud.git//modules/ecs"

  tags = local.common_tags
}
