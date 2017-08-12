# Infrastructure Provisioning Code for "DevOps Engineer - technical interview"

## Prerequisites

1. AWS account
1. AWS IAM user account with Admin permissions
1. git installation
1. Terraform installation

## Provisioned Resources
* VPC
* Subnet(s)
* NAT GW
* Internet GW
* Routing tables and associations
* Elastic IPs
* RDS instance
* Elastic Beanstalk environment

## Considerations

For the sake of simplicity, Terraform community modules were used in this project. They should be forked for usage in a real production environment.

## Deployment

1. Pull from Github:
    ```
    git clone git@github.com:venkain/devops-infra.git
    ```
1. Review and edit resourse parameters:
    ```
    cd devops-infra/terraform
    vi vars.tf
    ```
1. Initialize the environment:
    ```
    terraform init
    ```
1. Pull terraform modules:
    ```
    terraform get
    ```
1. Check Terraform plan:
    ```
    terraform plan
    ```
1. Provision:
    ```
    terraform apply
    ```
1. Provide resource attributes to developers:
    ```
    ...
    ```

Tested on macOS 10.12 with git 2.13.2, Terraform v0.10.0.
