variable "launcher_arn" {}

variable "launcher_role_name" {}

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
