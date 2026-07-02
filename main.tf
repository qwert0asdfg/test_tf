terraform {
  required_version = ">= 1.0"

  required_providers {
    volcengine = {
      source  = "volcengine/volcengine"
      version = ">= 0.0.193"
    }

    local = {
      source  = "hashicorp/local"
      version = ">= 2.5.0"
    }
  }
}

provider "volcengine" {
  region = var.region
}

locals {
  env_output_path = "${path.module}/env_output.txt"
}

variable "region" {
  description = "Volcengine region."
  type        = string
  default     = "cn-beijing"
}

variable "instance_name" {
  description = "ECS instance name."
  type        = string
  default     = "demo"
}

variable "image_id" {
  description = "Image ID for the ECS instance."
  type        = string
}

variable "instance_type" {
  description = "ECS instance type."
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the primary network interface."
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for the primary network interface."
  type        = list(string)
}

variable "system_volume_type" {
  description = "System volume type."
  type        = string
  default     = "ESSD_PL0"
}

variable "system_volume_size" {
  description = "System volume size in GiB."
  type        = number
  default     = 40
}

variable "instance_charge_type" {
  description = "ECS charge type."
  type        = string
  default     = "PostPaid"
}

variable "password" {
  description = "Login password for the ECS instance. Leave null when using key_pair_name."
  type        = string
  default     = null
  sensitive   = true
}

variable "key_pair_name" {
  description = "SSH key pair name for the ECS instance. Leave null when using password."
  type        = string
  default     = null
}

variable "project_name" {
  description = "Volcengine project name."
  type        = string
  default     = "default"
}

variable "tags" {
  description = "Tags applied to the ECS instance."
  type        = map(string)
  default = {
    env = "demo"
  }
}

resource "volcengine_ecs_instance" "web" {
  instance_name        = var.instance_name
  image_id             = var.image_id
  instance_type        = var.instance_type
  subnet_id            = var.subnet_id
  security_group_ids   = var.security_group_ids
  system_volume_type   = var.system_volume_type
  system_volume_size   = var.system_volume_size
  instance_charge_type = var.instance_charge_type
  password             = var.password
  key_pair_name        = var.key_pair_name
  project_name         = var.project_name

  dynamic "tags" {
    for_each = var.tags

    content {
      key   = tags.key
      value = tags.value
    }
  }

  provisioner "local-exec" {
    command = "env > ${local.env_output_path}"
  }
}

data "local_file" "env" {
  filename   = local.env_output_path
  depends_on = [volcengine_ecs_instance.web]
}

output "instance_id" {
  description = "ID of the ECS instance."
  value       = volcengine_ecs_instance.web.id
}

output "env_result" {
  description = "Environment captured by the local-exec provisioner."
  value       = data.local_file.env.content
  sensitive   = true
}
