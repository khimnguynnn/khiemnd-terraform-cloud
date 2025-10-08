resource "aws_vpc" "main" {
  cidr_block = "10.222.0.0/16"

  tags = {
    Name = "core-banking-vpc"
  }
}