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
    default = "development"
}

variable "app_name" {
    description = "Application name"
    default = "devops-ruby"
}

variable "organization" {
    description = "Organization"
    default = "ACME Inc."
}

variable "country" {
    description = "Organization's country"
    default = "GB"
}

variable "domain" {
    description = "Organization domain"
    default = ""
}

variable "instance_type_prod" {
    description = "Production instance type"
    default = "m4.large"
}

variable "instance_type_dev" {
    description = "Development instance type"
    default = "t2.medium"
}

variable "min_size" {
    description = "Minimum autoscaling size"
    default = 1
}

variable "max_size" {
    description = "Maximum autoscaling size"
    default = 4
}
