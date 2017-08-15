variable "profile" {
  description = "AWS user profile"
  default     = "default"
}

variable "region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment identifier"
  default     = "development"
}

variable "app_name" {
  description = "Application name"
  default     = "gitlab"
}

variable "organization" {
  description = "Organization"
  default     = "ACME Inc."
}

variable "country" {
  description = "Organization's country"
  default     = "GB"
}

variable "domain" {
  description = "Organization domain"
  default     = ""
}

variable "instance_type_prod" {
  description = "Production instance type"
  default     = "m4.large"
}

variable "instance_type_dev" {
  description = "Development instance type"
  default     = "t2.medium"
}

variable "min_size" {
  description = "Minimum autoscaling size"
  default     = 1
}

variable "max_size" {
  description = "Maximum autoscaling size"
  default     = 4
}

variable "gitlab_db_name" {
  description = "Gitlab DB name"
  default     = "gitlabdb"
}

variable "sns_alerts_arn" {
  description = "SNS topic ARN for autoscaling alerts."
  default     = ""
}

variable "ssh_public_key_names" {
  default = "venkain"
}
