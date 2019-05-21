locals {
  targets = "${var.targets}"

  bucket        = "${var.bucket}"
  bucket_prefix = "${var.bucket_prefix}"

  task_definition = "${var.task_definition}"

  queue_id  = "${var.queue_id}"
  queue_arn = "${var.queue_arn}"

  environment = "${var.environment}"

  common_prefix = "${var.common_prefix}"

  tags = "${var.tags}"
}

locals {
  external_environment = "${var.environment}"

  internal_environment = {
    BUCKET        = "${local.bucket}"
    BUCKET_PREFIX = "${local.bucket_prefix}"

    TASK_DEFINITION = "${local.task_definition}"

    QUEUE_ID  = "${local.queue_id}"
    QUEUE_ARN = "${local.queue_arn}"
  }
}

locals {
  final_environment = "${merge(local.external_environment, local.internal_environment)}"
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
  output_path = "${path.module}/build/handler.zip"
  name        = "${local.common_prefix}recon_handler"
  role_name   = "${local.common_prefix}recon_handler_role"

  timeout = 300

  environment = "${local.final_environment}"

  tags = "${local.tags}"

  depends_on = ["${module.targets_json.filename}"]
}

data "aws_iam_policy_document" "handler" {
  statement {
    effect = "Allow"

    resources = [
      "${local.queue_arn}",
    ]

    actions = [
      "sqs:SendMessage",
    ]
  }
}

resource "aws_iam_role_policy" "handler" {
  role = "${module.main.role_name}"

  policy = "${data.aws_iam_policy_document.handler.json}"
}
