module "redis" {
  source         = "github.com/terraform-community-modules/tf_aws_elasticache_redis?ref=1.0.0"
  env            = "${var.environment}"
  name           = "${var.app_name}-${var.environment}"
  redis_clusters = "${var.environment == "production" ? 2 : 1}"
  redis_failover = "${var.environment == "production" ? "true" : "false"}"
  subnets        = "${module.vpc.database_subnets}"
  vpc_id         = "${module.vpc.vpc_id}"
  allowed_security_groups = [ "${aws_security_group.app.id}" ]
  redis_node_type = "${var.environment == "production" ? "cache.m4.large" : "cache.t2.micro"}"
}
