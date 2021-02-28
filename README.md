# distributed-jenkins-aws
The end result of this project is to have a distributed Jenkins setup on a cloud platform that will function as the backbone of a CI/CD pipeline for software development.

This project uses several technologies used in the principles of DevOps. 
- **AWS** : data-center platform to host the infrastructure.
- **Terraform** : infrastructure-as-code (IaC) used to build and maintain the infrastructure
- **Ansible** : configuration management (CM) used to install and configure the tools, like Jenkins, on the hosts machines
- **Jenkins** : the main tool used for the continuous integration & continuous deployment/delivery CI/CD functionality

I personally use this repo for initial build-outs for other projects. 

# Notes

## terraform
- setup your `variables.tf` file first for the initial variables
- setup the `terraform.tfvars` file
- create a `backend` for an `s3` resource to host the `state` files
- create the initial `providers` for the AWS resources
- create the **networking**
    1. create the `vpc` resource(s) per region
    2. create the **internet gateway** (`igw`) resource per `vpc`
    3. create the `subnet` resources for each **AZ** in each `vpc`
- 