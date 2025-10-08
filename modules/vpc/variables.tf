variable "cidr_block" {
  description = "The CIDR block for the VPC."
  type        = string
}

variable "tags" {
  description = "A map of common tags to apply to all resources."
  type        = map(string)
}