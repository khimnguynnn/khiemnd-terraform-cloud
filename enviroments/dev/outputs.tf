output "network" {
  description = "The VPC ID where the ECS instances are deployed"
  value       = module.vpc.network_ids
}

output "ec2_private_key" {
  description = "The private IP addresses of the ECS instances"
  value       = module.ecs.private_key_pem
  sensitive   = true
}
