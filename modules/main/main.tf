locals {
  bucket        = "${var.bucket}"
  bucket_prefix = "${var.bucket_prefix}"

  targets = "${var.targets}"

  image = "${var.image}"

  schedule = "${var.schedule}"

  cluster_arn           = "${var.cluster_arn}"
  cluster_vpc_subnet_id = "${var.cluster_vpc_subnet_id}"

  common_prefix = "${var.common_prefix}"

  tags = "${var.tags}"
}

module "task" {
  source = "opendevsecops/ecs-task/aws"
  source = "0.0.3"

  name  = "${local.common_prefix}recon_runner"
  image = "${local.image}"
}

module "handler" {
  source = "../handler"

  bucket        = "${local.bucket}"
  bucket_prefix = "${local.bucket_prefix}"

  targets = "${local.targets}"

  task_definition = "${module.task.name}"

  cluster_arn           = "${local.cluster_arn}"
  cluster_vpc_subnet_id = "${local.cluster_vpc_subnet_id}"

  common_prefix = "${local.common_prefix}"

  tags = "${local.tags}"
}

module "schedule" {
  source = "../schedule"

  schedule = "${local.schedule}"

  handler_arn = "${module.handler.arn}"

  common_prefix = "${local.common_prefix}"

  tags = "${local.tags}"
}
