variable "bucket" {
  description = "Bucket for storage"
}

variable "bucket_prefix" {
  description = "Bucket prefix for storage"
}

variable "targets" {
  description = "Recon targets configuration"
}

variable "image" {
  description = "Docker container image"
  default     = "opendevsecops/terraform-aws-recon-runner:latest"
}

variable "schedule" {
  description = "Execution schedule"
  default     = "rate(7 days)"
}

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
