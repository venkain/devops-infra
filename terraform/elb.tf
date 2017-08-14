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
  name_prefix     = "app"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${module.vpc.vpc_id}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.app.arn}"
  port              = "443"
  protocol          = "HTTPS"
#  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${aws_iam_server_certificate.devops-cert.arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.arn}"
    type             = "forward"
  }
  lifecycle {
    create_before_destroy = true
  }
}

output "app_url" {
  value = "Please wait 5-10 minutes after initial deployment and open https://${aws_alb.app.dns_name}"
}
