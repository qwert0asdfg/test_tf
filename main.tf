terraform {
  required_version = ">= 1.5.7"
}

variable "command" {
  description = "Command kept for the execution platform. Terraform will not execute it because this configuration creates no resources."
  type        = string
  default     = "env"
}

output "command" {
  description = "Command value for the execution platform."
  value       = var.command
}
