locals {
  launcher_arn       = "${var.launcher_arn}"
  launcher_role_name = "${var.launcher_role_name}"

  common_prefix = "${var.common_prefix}"

  tags = "${var.tags}"
}

resource "aws_sqs_queue" "main" {
  name = "${local.common_prefix}recon_queue"

  visibility_timeout_seconds = 300

  tags = "${local.tags}"
}

data "aws_iam_policy_document" "main" {
  statement {
    effect = "Allow"

    resources = [
      "${aws_sqs_queue.main.arn}",
    ]

    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ChangeMessageVisibility",
    ]
  }
}

resource "aws_iam_role_policy" "main" {
  role = "${local.launcher_role_name}"

  policy = "${data.aws_iam_policy_document.main.json}"
}

resource "aws_lambda_event_source_mapping" "main" {
  event_source_arn = "${aws_sqs_queue.main.arn}"
  function_name    = "${local.launcher_arn}"

  depends_on = [
    "aws_iam_role_policy.main",
  ]
}
