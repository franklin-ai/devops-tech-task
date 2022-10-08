output "public_subnets" {
  description = "ids of public subnets (list)"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "ids of private subnets (list)"
  value       = module.vpc.private_subnets
}

output "vpc" {
  description = "id of the VPC"
  value       = module.vpc.vpc
}
