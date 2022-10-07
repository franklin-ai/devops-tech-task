terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

variable "gpg_key" {
  type        = string
  description = "gpg public key to use to encrypt terraform user aws secret key.\npleae see instructions to create this var in the file input.tfvars.example."
  nullable    = false
}

data "aws_caller_identity" "bootstrap" {}

resource "aws_iam_role" "terraform" {
  name = "terraform"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Action    = "sts:AssumeRole",
        Principal = { "AWS" : "arn:aws:iam::${data.aws_caller_identity.bootstrap.account_id}:root" }
    }]
  })

  tags = {
    role = "admin"
    name = "terraform"
  }
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.terraform.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_user" "terraform" {
  name          = "terraform"
  path          = "/system/"
  force_destroy = true

  tags = {
    role = "admin"
    name = "terraform"
  }
}

resource "aws_iam_user_policy" "terraform" {
  name = "terraform"
  user = aws_iam_user.terraform.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "sts:AssumeRole",
        Resource = "arn:aws:iam::${data.aws_caller_identity.bootstrap.account_id}:role/${aws_iam_role.terraform.name}"
    }]
  })
}

resource "aws_iam_access_key" "terraform" {
  user    = aws_iam_user.terraform.name
  pgp_key = var.gpg_key
}

output "terraform_role_arn" {
  value = aws_iam_role.terraform.arn
}

output "terraform_aws_key_id" {
  value = aws_iam_access_key.terraform.id
}

output "terraform_aws_key_secret" {
  value = aws_iam_access_key.terraform.encrypted_secret
}
