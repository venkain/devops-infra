# TODO: set region variable and pull AZs from data source

provider "aws" {
    region = "${var.region}"
    profile = "${var.profile}"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "devops-vpc-${var.environment}"

  cidr = "10.0.0.0/16"
  private_subnets = [ "10.0.1.0/24" ] # add more for real HA
  public_subnets  = [ "10.0.101.0/24" ] # add more for real HA
  database_subnets = [ "10.0.200.0/24", "10.0.201.0/24" ]

  enable_nat_gateway = "true"
  single_nat_gateway = "true"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"

  azs      = [ "${slice(data.aws_availability_zones.available.names, 0, 2)}" ]

  tags {
    "Terraform" = "true"
    "Environment" = "${var.environment}"
  }
}

resource "aws_security_group" "elb" {
  name        = "${var.app_name}-elb"
  description = "Allow inbound traffic to app's ELB"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.app_name}-elb"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.app_name}"
  description = "Allow inbound traffic to app"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${aws_security_group.elb.id}"]
  }

  tags {
    Name = "${var.app_name}"
  }
}

