resource "aws_route53_zone" "domain" {
  count = "${var.domain == "" ? 0 : 1}"
  name  = "${var.domain}"
}

resource "aws_route53_record" "www" {
  count   = "${var.domain == "" ? 0 : 1}"
  zone_id = "${aws_route53_zone.domain.zone_id}"
  name    = "${var.app_name}.${var.domain}"
  type    = "A"

  alias {
    name                   = "${aws_alb.app.dns_name}"
    zone_id                = "${aws_alb.app.zone_id}"
    evaluate_target_health = true
  }
}
