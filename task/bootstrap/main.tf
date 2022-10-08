terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {}

# gpg_key input variable to encrypt terraform user secret key
variable "gpg_key" {
  type        = string
  description = "gpg public key to use to encrypt terraform user aws secret key.\nplease see instructions to create this var in the file input.tfvars.example."
  nullable    = false
}

# our terraform user and role
# note: user and role are usually not in the same aws account
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

resource "aws_iam_user_policy" "terraform_role" {
  name = "terraform-role"
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

resource "aws_iam_user_policy" "terraform_remote" {
  name = "terraform-remote"
  user = aws_iam_user.terraform.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:GetObject", "s3:PutObject", "s3:DeleteObject"],
        Resource = ["${aws_s3_bucket.terraform.arn}", "${aws_s3_bucket.terraform.arn}/*"]
    }]
  })
}

resource "aws_iam_user_policy" "terraform_lock" {
  name = "terraform-lock"
  user = aws_iam_user.terraform.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"],
        Resource = aws_dynamodb_table.terraform.arn
    }]
  })
}

# terrform user access keys
resource "aws_iam_access_key" "terraform" {
  user    = aws_iam_user.terraform.name
  pgp_key = var.gpg_key
}

# s3 bucket for dependednt workspaces
resource "aws_s3_bucket" "terraform" {
  bucket = "devops-tech-task-tf-backend"

  tags = {
    role = "admin"
    name = "terraform"
  }
}

resource "aws_s3_bucket_acl" "terraform" {
  bucket = aws_s3_bucket.terraform.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "terraform" {
  bucket = aws_s3_bucket.terraform.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# dynamo db table for dependent workspaces
resource "aws_dynamodb_table" "terraform" {
  name           = "devops-tech-task-tf-backend"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    role = "admin"
    name = "terraform"
  }
}

# outputs - used by dependent workspaces
output "terraform_aws_key_id" {
  description = "terraform user access key id"
  value       = aws_iam_access_key.terraform.id
}

output "terraform_aws_key_secret" {
  description = "terraform user access key secret"
  value       = aws_iam_access_key.terraform.encrypted_secret
}

output "terraform_role_arn" {
  description = "terraform user admin role for aws provider"
  value       = aws_iam_role.terraform.arn
}
