variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "common_tags" {
  description = "A map of common tags to apply to all resources."
  type        = map(string)
}