# Infrastructure Provisioning Code for "DevOps Engineer - technical interview"

## Prerequisites

1. AWS account
1. AWS IAM user account with Admin permissions
1. git installation
1. Terraform installation

Tested on macOS 10.12 with git 2.13.2, Terraform v0.10.0.

## Deployment

1. Pull from Github:
```
git clone git@github.com:venkain/devops-infra.git
```
2. Review and edit resourse parameters:
```
cd devops-infra/terraform
vi vars.tf
```
3. Check Terraform plan:
```
terraform plan
```
4. Provision:
```
terraform apply
```
5. Provide resource attributes to developers:
```
...
```
