module "redis" {
  source          = "github.com/terraform-community-modules/tf_aws_elasticache_redis"
  env             = "${var.environment}"
  name            = "${var.app_name}-${var.environment}"
  redis_clusters  = "${var.environment == "production" ? 2 : 1}"
  redis_failover  = "${var.environment == "production" ? "true" : "false"}"
  subnets         = "${module.vpc.database_subnets}"
  vpc_id          = "${module.vpc.vpc_id}"
  redis_node_type = "${var.environment == "production" ? "cache.m4.large" : "cache.t2.micro"}"
}

resource "aws_security_group_rule" "redis" {
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.app.id}"
  security_group_id        = "${module.redis.redis_security_group_id}"
}
