variable "targets" {}

variable "bucket" {}

variable "bucket_prefix" {}

variable "task_definition" {}

variable "cluster_arn" {}

variable "cluster_vpc_subnet_id" {}

variable "public_ip" {
  default = false
}

variable "common_prefix" {
  default = "opendevsecops_"
}
