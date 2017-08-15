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

data "template_file" "user_data" {
  template = "${file("user_data.sh")}"

  vars {
    url            = "https://${var.domain == "" ? aws_alb.app.dns_name : join(".", list(var.app_name, var.domain))}"
    postgres_url   = "${module.rds.rds_instance_address}"
    db_name        = "${var.database_name}"
    gitlab_db_name = "${var.gitlab_db_name}"
    db_user        = "${var.database_user}"
    db_password    = "${var.database_password}"
    redis_url      = "${module.redis.endpoint}"
    s3_bucket_name = "${aws_s3_bucket.ssh_public_keys.id}"
    s3_bucket_uri  = ""

    # TODO: fix EFS target
    efs_url = "${aws_efs_mount_target.app_1.dns_name}"
  }
}

resource "aws_launch_configuration" "app" {
  name_prefix     = "terraform-lc-${var.app_name}-"
  image_id        = "${data.aws_ami.ubuntu.id}"
  instance_type   = "${var.environment == "production" ? var.instance_type_prod : var.instance_type_dev}"
  security_groups = ["${aws_security_group.app.id}"]

  lifecycle {
    create_before_destroy = true
  }

  user_data = "${data.template_file.user_data.rendered}"
}

resource "aws_autoscaling_group" "app" {
  name                      = "${var.app_name}"
  max_size                  = "${var.max_size}"
  min_size                  = "${var.min_size}"
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = "${var.min_size}"
  force_delete              = true

  # placement_group           = "${aws_placement_group.app.id}"
  launch_configuration = "${aws_launch_configuration.app.name}"
  vpc_zone_identifier  = ["${module.vpc.private_subnets}"]

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]

  lifecycle {
    create_before_destroy = true
  }

  timeouts {
    delete = "15m"
  }

  tag {
    key                 = "Name"
    value               = "${var.app_name}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Terraform"
    value               = "true"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = "${var.environment}"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_attachment" "app" {
  autoscaling_group_name = "${aws_autoscaling_group.app.id}"
  alb_target_group_arn   = "${aws_alb_target_group.app.arn}"
}

resource "aws_autoscaling_notification" "email_alerts" {
  count       = "${var.sns_alerts_arn == "" ? 0 : 1}"
  group_names = ["${aws_autoscaling_group.app.name}"]

  notifications = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
  ]

  topic_arn = "${var.sns_alerts_arn}"
}
