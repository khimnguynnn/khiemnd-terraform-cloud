terraform {
  backend "remote" {
    organization = "khiemnd-terraform-cloud-labs"

    workspaces {
      name = "core-banking-dev"
    }
  }
}
