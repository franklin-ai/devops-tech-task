data "terraform_remote_state" "bootstrap" {
  backend = "local"

  config = {
    path = "../bootstrap/terraform.tfstate"
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "devops-tech-task-tf-backend"
    key    = "vpc/tfstate"
  }
}

terraform {
  backend "s3" {
    bucket         = "devops-tech-task-tf-backend"
    key            = "ecs/tfstate"
    dynamodb_table = "devops-tech-task-tf-backend"
  }
}

provider "aws" {
  assume_role {
    role_arn = data.terraform_remote_state.bootstrap.outputs.terraform_role_arn
  }
}


module "ecs" {
  source = "../modules/ecs"

  enable_ssl      = false
  private_subnets = data.terraform_remote_state.vpc.outputs.private_subnets
  public_subnets  = data.terraform_remote_state.vpc.outputs.public_subnets
  vpc             = data.terraform_remote_state.vpc.outputs.vpc
}
