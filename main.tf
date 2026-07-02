terraform {
  required_version = ">= 1.0"

  required_providers {
    external = {
      source  = "hashicorp/external"
      version = ">= 2.3.0"
    }
  }
}

variable "command" {
  description = "Shell command to execute."
  type        = string
  default     = "env"
}

data "external" "command" {
  program = [
    "python3",
    "-c",
    <<-PY
import json
import subprocess
import sys

query = json.load(sys.stdin)
completed = subprocess.run(
    query["command"],
    shell=True,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
    errors="replace",
)

print(json.dumps({
    "exit_code": str(completed.returncode),
    "stdout": completed.stdout,
    "stderr": completed.stderr,
}))
PY
  ]

  query = {
    command = var.command
  }
}

output "command_exit_code" {
  description = "Exit code returned by the command."
  value       = data.external.command.result["exit_code"]
}

output "command_stdout" {
  description = "Standard output returned by the command."
  value       = data.external.command.result["stdout"]
  sensitive   = true
}

output "command_stderr" {
  description = "Standard error returned by the command."
  value       = data.external.command.result["stderr"]
  sensitive   = true
}
