variable "targets" {}

variable "bucket" {}

variable "bucket_prefix" {}

variable "task_definition" {}

variable "cluster_arn" {}

variable "cluster_vpc_subnet_id" {}

variable "common_prefix" {
  default = "opendevsecops_"
}

variable "tags" {
  default = {}
}

# depends_on workaround

variable "depends_on" {
  description = "Helper variable to simulate depends_on for terraform modules"
  default     = []
}
