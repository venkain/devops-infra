resource "aws_efs_file_system" "app" {
  creation_token = "${var.app_name}-${var.environment}"

  tags {
    Name = "${var.app_name}-${var.environment}"
  }
}

resource "aws_efs_mount_target" "app_1" {
  file_system_id = "${aws_efs_file_system.app.id}"
  subnet_id      = "${module.vpc.private_subnets[0]}"
  security_groups = ["${aws_security_group.app.id}"]
}

resource "aws_efs_mount_target" "app_2" {
  file_system_id = "${aws_efs_file_system.app.id}"
  subnet_id      = "${module.vpc.private_subnets[1]}"
  security_groups = ["${aws_security_group.app.id}"]
}
