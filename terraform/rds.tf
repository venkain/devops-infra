module "rds" {
  source = "github.com/terraform-community-modules/tf_aws_rds"

  # RDS Instance Inputs
  rds_instance_identifier = "${var.rds_instance_identifier}-${var.environment}"
  rds_allocated_storage   = "${var.rds_allocated_storage}"
  rds_engine_type         = "${var.rds_engine_type}"
  rds_instance_class      = "${var.rds_instance_class}"
  rds_engine_version      = "${var.rds_engine_version}"
  db_parameter_group      = "${var.db_parameter_group}"
  rds_is_multi_az         = "${var.environment == "production" ? "true" : "false"}"

  database_name     = "${var.database_name}"
  database_user     = "${var.database_user}"
  database_password = "${var.database_password}"
  database_port     = "${var.database_port}"

  # Upgrades
  // allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  // auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"


  // apply_immediately           = "${var.apply_immediately}"
  // maintenance_window          = "${var.maintenance_window}"


  # Snapshots and backups
  // skip_final_snapshot   = "${var.skip_final_snapshot}"
  // copy_tags_to_snapshot = "${var.copy_tags_to_snapshot}"

  # DB Subnet Group Inputs
  subnets    = ["${module.vpc.database_subnets}"]
  rds_vpc_id = "${module.vpc.vpc_id}"
  // private_cidr = ["${var.private_cidr}"]
  private_cidr = ["10.0.0.0/16"]
  tags {
    "Terraform"   = "true"
    "Environment" = "${var.environment}"
  }
}
