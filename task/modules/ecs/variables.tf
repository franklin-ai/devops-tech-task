variable "enable_ssl" {
  description = "whether to enable ssl (boolean)"
  type        = bool
  default     = false
}

variable "public_subnets" {
  description = "a list of public subnet ids inside the vpc"
  type        = list(string)
}

variable "private_subnets" {
  description = "a list of private subnet ids inside the vpc"
  type        = list(string)
}

variable "vpc" {
  description = "id of the vpc used by the ecs service"
  type        = string
}
