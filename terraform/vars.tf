variable "profile" {
    description = "AWS user profile"
    default = "venkain"
}

variable "region" {
    description = "AWS region"
    default = "us-east-1"
}

variable "environment" {
    description = "Environment identifier"
    default = "Development"
}

variable "rds_instance_identifier" {
    description = "RDS instance identifier"
    default = "devops-db"
}

variable "rds_is_multi_az" {
    description = "Is the RDS multi-AZ"
    default = false
}

variable "rds_storage_type" {
    description = "RDS storage type"
    default = "gp2"
}

variable "rds_iops" {
    description = "Provisioned IOPS, if rds_storage_type -s io1"
    default = 0
}

variable "rds_allocated_storage" {
    description = "Allocated storage"
    default = 10
}
variable "rds_engine_type" {
    description = "RDS engine type"
    default = "postgres"
}

variable "rds_engine_version" {
    description = "RDS engine version"
    default = "9.6"
}

variable "rds_instance_class" {
    description = "RDS instance class"
    default = "db.t2.micro"
}

variable "database_name" {
    description = "DB name"
    default = "devopsdb"
}

variable "database_user" {
    description = "DB user name"
    default = "devops"
}

variable "database_password" {
    description = "DB user password"
    default = "correcthorsebatterystaple:)"
}

variable "database_port" {
    description = "DB port"
    default = 5432
}

variable "db_parameter_group" {
    description = "DB parmeter group"
    default = "postgres9.6"
}
// subnets
// publicly_accessible
// private_cidr
// rds_vpc_id
// allow_major_version_upgrade
// auto_minor_version_upgrade
// apply_immediately
// maintenance_window
// skip_final_snapshot
// copy_tags_to_snapshot
// backup_retention_period
// backup_window
// tags
