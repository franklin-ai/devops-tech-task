# Technical Task for franklin.ai DevOps Engineer Roles

This is a technical task for DevOps Engineer roles at [franklin.ai](https://franklin.ai).

## Task

### Part 1 - Building the Docker image

This repository contains a **hello-world-server** directory which defines a simple, web server written in Rust. Part 1 of the task is to build the **hello-world-server** into a Docker image.

You may use a Dockerfile/Docker CLI or any build or CI framework you choose to build the Docker image. The Docker image should meet the following criteria:

- Apply Docker best practices in how you build and add security to the image.
- The default CMD or ENTRYPOINT of the image should run the **hello-world-server** binary. 
- Ensure the `hello-world-server/static` directory is copied into the image. The **hello-world-server** binary expects to find it at the `./static` path relative to itself.
- You should not need to edit anything within the **hello-world-server** directory. Instead you should simply add a Dockerfile or whatever you need to build the Docker image.

Note that the **hello-world-server** listens on TCP port 80. This will be relevant for when you run the container in part 2.

Also note that you can build the **hello-world-server** binary by running the following command within the `hello-world-server` directory:

```sh
cargo build --all-features -p hello-world-server --release
```

The compiled binary will be written to `hello-world-server/target/release/hello-world-server`.

### Part 2 - Running the Docker container in AWS

In part 2 you should use [Terraform](https://www.terraform.io/) to provision an application stack in a single region of AWS that runs the **hello-world-server**. While you must use Terraform for provisioning the AWS resources, you may use a script or any build framework you wish to push the **hello-world-server** Docker image to a repository or object store so that it can be pulled and run by your chosen AWS compute.

The Terraform stack should meet the following criteria:

- Apply best practices in solution architecture and security.
- Run the **hello-world-server** Docker container and ensure it's accessible over HTTP and/or HTTPS (HTTPS is a bonus by not necessary for the purposes of this exercise).
- Scale capacity to meet demand.
- Manage unhealthy instances.

You may choose to include all components from the network (i.e. VPC) up, in the stack.
However, given the amount of effort involved, you can also exclude the network, subnets, and associated networking components from your stack and configure them as input variables to be provided by ourselves upon deployment.

You can assume the following about the environment into which your stack will be deployed:

- A VPC with public and private subnets in up to 3 x Availability Zones.
- Internet Gateway and NAT Gateway present to allow outbound internet connectivity to TCP/80 and TCP/443 from all subnets in the network.

## Expectations

To complete the task you should take a copy of this repo and publish your solution to your own version of the repository.
You are welcome to make your repository private as long as it is visible to `@doc-E-brown`, `@cmac-fish`, `@rickfoxcroft`, `@jayvdb` and `@michaelvoet`.
You will not be required to demonstrate an operational version of your solution, however please provide the listed members with access at least 24 hours prior to the scheduled technical interview.

**Please do not spend more than a few hours on this task**

You are welcome to use a number of published boilerplate templates provided you modify them enough to demonstrate your own skills.
Please include a README, citing any third-party code, tutorials or documentation you have used.
If your solution includes any unusual deployment steps, please note them in your README file.
As described above we will be deploying your solution within our own infrastructure, please outline the steps your solutions require for a successful deployment.
If you have chosen to exclude the networking components from your solution and provide them as input variables, please note the requirements in the README.

## Interview Discussions

Your solution will form the starting point of a technical interview, during which we will discuss various design choices, potential future enhancements or refactoring.
In preparation for the interview, please consider how you would answer the following questions. How would you:

- provide shell access into the application stack for operations staff who may want to log into an instance?
- make access and error logs available in a monitoring service such as AWS CloudWatch or Azure Monitor?

**Credits:** thanks to @ImperialXT for his work in writing the original version of this task from which this document was sourced.
