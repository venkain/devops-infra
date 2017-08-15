# Infrastructure Provisioning Code for "DevOps Engineer - technical interview"
Sets up Gitlab and, if enabled, Elastic Beanstalk Ruby environment.
## Prerequisites

1. AWS account
1. AWS IAM user profile with Admin permissions
1. git
1. Terraform
1. SSH key pair

## Provisioned Resources
* VPC
* Subnet(s)
* Security groups
* NAT GW
* Internet GW
* Routing tables and associations
* Elastic IPs
* RDS instance
* Redis instance
* Elastic file system
* Application load balancer
* Auto scaling group with HA EC2 instance(s)
* Bastion host
* DNS domain record (optional)
* Elastic Beanstalk environment (disabled)

## Considerations

For the sake of simplicity, several Terraform community modules were used in this project. They should be forked for usage in a real production environment.

## Known Issues
* SNS topic creation with **email** protocol is unsupported by Terraform according to the [documentation](https://www.terraform.io/docs/providers/aws/r/sns_topic_subscription.html).
* SSH key pair generation is also unsupported.
* The lack of own domain did not allow me to test the Route 53-based domain record and SSL certificate properly.
* Application logging and monitoring were considered but dropped as being out of scope.
* SSH keys are added to the existing user *ubuntu*.

## Deployment

1. Pull from Github:
    ```
    git clone git@github.com:venkain/devops-infra.git
    ```
1. Review and edit resourse parameters:
    ```
    cd devops-infra/terraform
    vi vars.tf
    vi rds_vars.tf
    ```
1. Copy the public keys you want to use:
    ```
    cp ~/.ssh/my_key.pub public_keys
    ```
1. Initialize the environment:
    ```
    terraform init
    ```
1. Check Terraform plan:
    ```
    terraform plan
    ```
    or with variable overrides:
    ```
    terraform plan -var profile=my_profile -var domain=mydomain.com
    ```
1. Provision:
    ```
    terraform apply
    ```
    or with variable overrides:
    ```
    terraform apply -var profile=my_profile -var domain=mydomain.com
    ```
1. Access the environment

    Check the output values of `terraform plan` or `terraform output`.
## Disclaimer
The code was tested on macOS 10.12 and Ubuntu 16.04 with git 2.13.2 and Terraform v0.10.0, and is not guaranteed to work on other platforms or versions. Production environment was not tested and might not work as expected.
