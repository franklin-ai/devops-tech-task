# bootstrap

## Minimal code for creating a machine user to apply terraform plans to an AWS account

Before applying the changes we need to run the ecs hello world service, we first want to designate an IAM user in the account for terraform to use. The code in this directory creates the "terraform" user and the "terraform" role which the user assumes during a terraform run. For now, this terraform role has administraor access to the AWS account.

If we are starting out with a brand new AWS account, then we want to use the root account user to apply this code. Also, we generally want to perform the terraform commands on our host machine, via the cli. And we do want to commit the state file produced to this git repository. Once the terraform user and role are creaed, it is unlikely we will need to change the configuration.

To run:
Assign the root user an AWS key and secret key. Export those keys to the host environment.

*  `export AWS_ACCESS_KEY_ID="< root user aws key >"`
*  `export AWS_SECRET_ACCESS_KEY="< root user aws secret key >"`

Copy the `input.tfvars.example` file to `input.tfvars` and add the value for the gpg_key variable (instructions are in the input.tfvars.example file).

Terraform plan.

*  `terraform plan -var-file="input.tfvars"`

Terraform apply.

*  `terraform apply -var-file="input.tfvars"`

Make sure to commit the new terraform.tfstate file to this git repository.

If you no longer need the root AWS keys, delete them.

Both the vpc and ecs terraform spaces will use this new terraform user to apply changes. You will need to retrieve this user's AWS keys which are available here as outputs. To unencrypt the secret key, run `terraform output -raw terraform_aws_key_secret | base64 --decode | gpg --decrypt` (you may need to adjust the command if you are not using a gpg key imported into your host's gpg configuration).

When considering security best practices, usually the terraform user configuration spans multiple AWS accounts. Usually there is an admin designated accout that contains the user while the account that will hold the resources contains the role. For the purposes of this exercise, both the user and role exist in the same AWS account.
