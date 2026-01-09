# modules/compute/variables.tf

variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "security_group" { type = string }
variable "project_name" { type = string }

variable "AWS_SSH_KEY" {
  description = "Name of existing AWS key pair"
  type        = string
}

variable "AWS_SSH_KEY_CONTENT" {
  description = "Content of private key (PEM)"
  type        = string
  sensitive   = true
}