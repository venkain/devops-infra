# Infrastructure Provisioning Code for "DevOps Engineer - technical interview"
Sets up Gitlab and, if enabled, Elastic Beanstalk Ruby environment.
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
* Application load balancer
* Auto scaling group with HA EC2 instance(s)
* Elastic Beanstalk environment (disabled)

## Considerations

For the sake of simplicity, several Terraform community modules were used in this project. They should be forked for usage in a real production environment.

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
    terraform output
    ```

Tested on macOS 10.12 with git 2.13.2, Terraform v0.10.0.
