# TODO: create SNS topic for notifications

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_launch_configuration" "app" {
  name_prefix   = "terraform-lc-${var.app_name}-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.environment == "production" ? var.instance_type_prod : var.instance_type_dev}"
  security_groups = [ "${aws_security_group.app.id}" ]

  lifecycle {
    create_before_destroy = true
  }
  // enable_monitoring = false
#   iam_instance_profile =
# Remove after test
  key_name = "venkain"
  user_data = "${file("user_data.sh")}"
}

resource "aws_autoscaling_group" "app" {
  availability_zones        = [ "${slice(data.aws_availability_zones.available.names, 0, 2)}" ]
  name                      = "${var.app_name}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 1
  force_delete              = true
  # placement_group           = "${aws_placement_group.app.id}"
  launch_configuration      = "${aws_launch_configuration.app.name}"
  vpc_zone_identifier = [ "${module.vpc.private_subnets}" ]

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key = "Terraform"
    value = "true"
    propagate_at_launch = true
  }

  tag {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = "${aws_autoscaling_group.app.id}"
  alb_target_group_arn   = "${aws_alb_target_group.app.arn}"
}
