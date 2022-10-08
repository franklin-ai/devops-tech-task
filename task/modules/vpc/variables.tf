variable "cidr" {
  description = "ipv4 cidr block for the vpc"
  type        = string
}

variable "public_subnets" {
  description = "a list of public subnets inside the vpc"
  type        = list(string)
}

variable "private_subnets" {
  description = "a list of private subnets inside the vpc"
  type        = list(string)
}
