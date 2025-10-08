variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "ap-southeast-1"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}