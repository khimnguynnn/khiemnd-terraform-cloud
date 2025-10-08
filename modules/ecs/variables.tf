variable "ecs_ami" {
  description = "The AMI ID for the ECS instances"
  type        = string
  default     = "ami-0ad0fbc938446fbd5"
}

variable "vpc_id" {
  description = "The VPC ID where the ECS instances will be deployed"
  type        = string
}

variable "allowed_ports" {
  description = "A list of allowed ports for the ECS instances"
  type        = list(string)
  default     = ["22", "80", "443"]
}

variable "ecs_instance_type" {
  description = "The instance type for the ECS instances"
  type        = string
  default     = "t3.micro"
}

variable "private_subnet_cidrs" {
  description = "A list of private subnet IDs for the ECS instances"
  type        = list(string)
  default     = []
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

output "private_key_pem" {
  description = "Private key for SSH access to EC2 instances"
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}