output "private_subnets" {
  description = "ids of private subnets (list)"
  value       = values(aws_subnet.private)[*].id
}

output "public_subnets" {
  description = "ids of public subnets (list)"
  value       = values(aws_subnet.public)[*].id
}

output "vpc" {
  description = "id of the VPC"
  value       = aws_vpc.self.id
}
