locals {
  bucket        = "${var.bucket}"
  bucket_prefix = "${var.bucket_prefix}"

  targets = "${var.targets}"

  image = "${var.image}"

  schedule = "${var.schedule}"

  cluster_vpc_cidr_block        = "${var.cluster_vpc_cidr_block}"
  cluster_vpc_subnet_cidr_block = "${var.cluster_vpc_subnet_cidr_block}"

  public_ip = "${var.public_ip}"

  common_prefix = "${var.common_prefix}"

  tags = "${var.tags}"
}

module "cluster" {
  source = "opendevsecops/ecs-cluster/aws"
  source = "0.7.0"

  name = "${local.common_prefix}recon_cluster"

  vpc_cidr_block        = "${local.cluster_vpc_cidr_block}"
  vpc_subnet_cidr_block = "${local.cluster_vpc_subnet_cidr_block}"
}

module "main" {
  source = "modules/main"

  bucket        = "${local.bucket}"
  bucket_prefix = "${local.bucket_prefix}"

  targets = "${local.targets}"

  image = "${local.image}"

  schedule = "${local.schedule}"

  cluster_arn           = "${module.cluster.arn}"
  cluster_vpc_subnet_id = "${module.cluster.vpc_subnet_id}"

  public_ip = "${local.public_ip}"

  common_prefix = "${local.common_prefix}"

  tags = "${local.tags}"
}
