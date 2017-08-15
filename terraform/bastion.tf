data "aws_caller_identity" "current" {}

resource "aws_iam_instance_profile" "s3_readonly" {
  name = "s3_readonly"
  role = "${aws_iam_role.s3_readonly.name}"
}

resource "aws_iam_role" "s3_readonly" {
  name = "s3_readonly"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_readonly_policy" {
  name = "s3_readonly-policy"
  role = "${aws_iam_role.s3_readonly.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Stmt1425916919000",
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_s3_bucket" "ssh_public_keys" {
  region = "${var.region}"
  bucket = "${var.app_name}-${var.environment}-public-keys"
  acl    = "private"

  policy = <<EOF
{
	"Version": "2008-10-17",
	"Id": "Policy142469412148",
	"Statement": [
		{
			"Sid": "Stmt1424694110324",
			"Effect": "Allow",
			"Principal": {
				"AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
			},
			"Action": [
				"s3:List*",
				"s3:Get*"
			],
			"Resource": "arn:aws:s3:::${var.app_name}-${var.environment}-public-keys"
		}
	]
}
EOF
}

resource "aws_s3_bucket_object" "ssh_public_keys" {
  bucket = "${aws_s3_bucket.ssh_public_keys.bucket}"
  key    = "${element(split(",", var.ssh_public_key_names), count.index)}.pub"

  # Make sure that you put files into correct location and name them accordingly (public_keys/{keyname}.pub)
  content = "${file("public_keys/${element(split(",", var.ssh_public_key_names), count.index)}.pub")}"
  count   = "${length(split(",", var.ssh_public_key_names))}"

  depends_on = ["aws_s3_bucket.ssh_public_keys"]
}

resource "aws_eip" "bastion" {
  vpc = true
}

module "bastion" {
  source                      = "github.com/terraform-community-modules/tf_aws_bastion_s3_keys"
  eip                         = "${aws_eip.bastion.public_ip}"
  instance_type               = "t2.micro"
  ami                         = "${data.aws_ami.ubuntu.id}"
  region                      = "${var.region}"
  iam_instance_profile        = "s3_readonly"
  s3_bucket_name              = "${var.app_name}-${var.environment}-public-keys"
  vpc_id                      = "${module.vpc.vpc_id}"
  subnet_ids                  = ["${module.vpc.public_subnets}"]
  keys_update_frequency       = "5,20,35,50 * * * *"
  additional_user_data_script = "apt -y install postgresql-client"
}
