# TODO: set region variable and pull AZs from data source

provider "aws" {
    region = "us-east-1"
    profile = "${var.profile}"
}

module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "devops-vpc"

  cidr = "10.0.0.0/16"
  private_subnets = [ "10.0.1.0/24" ]
  public_subnets  = [ "10.0.101.0/24" ]

  enable_nat_gateway = "true"

  azs      = [ "us-east-1a" ]

  tags {
    "Terraform" = "true"
    "Environment" = "${var.environment}"
  }
}

