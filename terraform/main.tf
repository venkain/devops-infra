# TODO: add bastion and ssh key

provider "aws" {
    region = "${var.region}"
    profile = "${var.profile}"
}

data "aws_availability_zones" "available" {}

module "vpc" {
  source = "github.com/terraform-community-modules/tf_aws_vpc"

  name = "devops-vpc-${var.environment}"

  cidr = "10.0.0.0/16"
  private_subnets = [ "10.0.1.0/24", "10.0.2.0/24" ]
  public_subnets  = [ "10.0.101.0/24", "10.0.102.0/24" ]
  database_subnets = [ "10.0.201.0/24", "10.0.202.0/24" ]

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
  description = "Allow inbound traffic to the ELB"
  vpc_id = "${module.vpc.vpc_id}"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.app_name}-elb"
  }
}

resource "aws_security_group" "app" {
  name        = "${var.app_name}"
  description = "Allow inbound traffic to the app"
  vpc_id = "${module.vpc.vpc_id}"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    // cidr_blocks     = ["10.0.0.0/16"]
    security_groups = ["${aws_security_group.elb.id}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.app_name}"
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type            = "ingress"
  from_port       = 22
  to_port         = 22
  protocol        = "tcp"
  source_security_group_id = "${aws_security_group.app.id}"
  security_group_id = "${aws_security_group.app.id}"
}
