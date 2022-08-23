# Technical Task for franklin.ai DevOps Engineer Roles

This is a technical task for DevOps Engineer roles at [franklin.ai](https://franklin.ai).

## Task

Using an [terraform](https://www.terraform.io/), create a template that defines an application stack in a single region of AWS.

The stack should meet the following criteria:

- Apply best practices in solution architecture and security.
- Use an official, public, Debian, Ubuntu or Amazon Linux image for any EC2 or Container resources.
- Serve a basic "Hello, World" webpage.
- Scale capacity to meed demand.
- Manage unhealthy instances.
- Your application stack may or may not be containerised.
- Serving your "Hello, World" page over HTTPS is an added bonus, but not necessary for the purposes of this exercise.

You may chose to include all components from the network (ie. VPC) up, in the stack.
However, given the amount of effort involved, you can also exclude the network, subnets, and associated networking components from your stack and configure them as input variables to be provided by ourselves upon deployment.

You can assume the following about the environment into which your stack will be deployed:

- A VPC with public and private subnets in up to 3 x Availability Zones.
- Internet Gateway and NAT Gateway present to allow outbound internet connectivity to TCP/80 and TCP/443 from all subnets in the network.

## Expectations

To complete the task you should take a copy of this repo and publish your solution to your own version of the repository.
You are welcome to make your repository private as long as it is visible to `@doc-E-brown`, `@cmac-fish`, `@rickfoxcroft` and `@jayvdb`.
You will not be required to demonstrate an operational version of your solution, however please provide the listed members with access at least 24 hours prior to the scheduled technical interview.


**Please do not spend more than a few hours on this task**

You are welcome to use a number of published boilerplate templates provided you modify them enough to demonstrate your own skills.
Please include a README, citing any third-party code, tutorials or documentation you have used.
If your solution includes any unusual deployment steps, please note them in your README file.
As described above we will be deploying your solution within our own infrastructure, please outline the steps your solutions requires for a successful deployment.
If you have chosen to exclude the networking components from your solution and provide them as input variables, please note the requirements in the README.

## Interview Discussions 

Your solution will form the starting point of a technical interview, during which we will discuss various design choices, potential future enhancements or refactoring.
In preparation for the interview, please consider how you would answer the following questions.  How would you:

- provide shell access into the application stack for operations staff who may want to log into an instance?
- make access and error logs available in a monitoring service such as AWS CloudWatch or Azure Monitor?

**Credits:** thanks to @ImperialXT for his work in writing the original version of this task from which this document was sourced.