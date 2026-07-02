terraform {
  required_version = ">= 1.4"
}

variable "command" {
  description = "Shell command to execute."
  type        = string
  default     = "env"
}

resource "terraform_data" "command" {
  input = var.command

  triggers_replace = [
    var.command,
    timestamp(),
  ]

  provisioner "local-exec" {
    command = self.input
  }
}

output "command" {
  description = "Command executed by local-exec."
  value       = terraform_data.command.output
}
