resource "aws_alb" "app" {
  name            = "${var.app_name}"
  internal        = false
  security_groups = ["${aws_security_group.elb.id}"]
  subnets         = ["${module.vpc.public_subnets}"]

  enable_deletion_protection = true

  # access_logs {
  #   bucket = "${aws_s3_bucket.alb_logs.bucket}"
  #   prefix = "${var.app_name}"
  # }

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_alb_target_group" "app" {
  name     = "${var.app_name}"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.id}"
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.app.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = ""
  certificate_arn   = ""

  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type             = "forward"
  }
}