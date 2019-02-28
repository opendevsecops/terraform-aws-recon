locals {
  schedule = "${var.schedule}"

  handler_arn = "${var.handler_arn}"

  common_prefix = "${var.common_prefix}"

  tags = "${var.tags}"
}

resource "aws_cloudwatch_event_rule" "main" {
  name                = "${local.common_prefix}recon_schedule"
  schedule_expression = "${local.schedule}"
}

resource "aws_cloudwatch_event_target" "main" {
  rule = "${aws_cloudwatch_event_rule.main.name}"
  arn  = "${local.handler_arn}"

  input = <<EOF
{"op": "schedule"}
EOF
}

resource "aws_lambda_permission" "main" {
  action        = "lambda:InvokeFunction"
  function_name = "${local.handler_arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.main.arn}"
}
