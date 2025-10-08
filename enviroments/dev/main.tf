locals {
  common_tags = {
    Owner       = "khiemnd"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "core-banking"
  }
}


module "vpc" {
  source = "git::https://github.com/khimnguynnn/khiemnd-terraform-cloud.git//modules/vpc"

  cidr_block = var.cidr_block
  tags       = local.common_tags
}
