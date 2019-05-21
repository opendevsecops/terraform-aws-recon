locals {
  targets = "${var.targets}"

  bucket        = "${var.bucket}"
  bucket_prefix = "${var.bucket_prefix}"

  task_definition = "${var.task_definition}"

  cluster_arn           = "${var.cluster_arn}"
  cluster_vpc_subnet_id = "${var.cluster_vpc_subnet_id}"

  public_ip = "${var.public_ip}"

  common_prefix = "${var.common_prefix}"

  tags = "${var.tags}"
}

module "roles" {
  source = "opendevsecops/ecs-cluster/aws//modules/roles"
  source = "0.7.0"
}

resource "aws_iam_role_policy" "task_role_policy" {
  role = "${module.roles.task_role_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::${local.bucket}${local.bucket_prefix}/*"
      ]
    }
  ]
}
EOF
}

module "targets_json" {
  source  = "opendevsecops/file/local"
  version = "0.1.0"

  filename = "${path.module}/src/targets.json"
  content  = "${local.targets}"
}

module "main" {
  source  = "opendevsecops/lambda/aws"
  version = "0.3.0"

  source_dir  = "${path.module}/src/"
  output_path = "${path.module}/build/launcher.zip"
  name        = "${local.common_prefix}recon_launcher"
  role_name   = "${local.common_prefix}recon_launcher_role"

  timeout = 300

  environment {
    CLUSTER_ARN           = "${local.cluster_arn}"
    CLUSTER_VPC_SUBNET_ID = "${local.cluster_vpc_subnet_id}"

    PUBLIC_IP = "${local.public_ip ? "true" : "false"}"

    TASK_ROLE_ARN      = "${module.roles.task_role_arn}"
    EXECUTION_ROLE_ARN = "${module.roles.execution_role_arn}"

    TASK_DEFINITION = "${local.task_definition}"

    BUCKET        = "${local.bucket}"
    BUCKET_PREFIX = "${local.bucket_prefix}"
  }

  tags = "${local.tags}"

  depends_on = ["${module.targets_json.filename}"]
}

resource "aws_iam_role_policy" "main_role_policy" {
  name = "policy"
  role = "${module.main.role_name}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "ecs:RunTask",
      "Resource": "*",
      "Condition": {
        "ArnEquals": {
          "ecs:cluster": "${local.cluster_arn}"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "${module.roles.task_role_arn}"
    },
    {
      "Effect": "Allow",
      "Action": "iam:PassRole",
      "Resource": "${module.roles.execution_role_arn}"
    }
  ]
}
EOF
}
