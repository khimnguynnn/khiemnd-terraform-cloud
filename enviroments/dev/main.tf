locals {
  git_repo = "git::https://github.com/khimnguynnn/khiemnd-terraform-cloud.git"
  common_tags = {
    Owner       = "khiemnd"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "core-banking"
  }
}


module "vpc" {
  source = "${local.git_repo}//modules/vpc"
}
