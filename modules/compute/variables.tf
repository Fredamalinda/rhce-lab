# modules/compute/variables.tf

variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "security_group" { type = string }
variable "project_name" { type = string }

variable "aws_ssh_key" {
  description = "Name of existing AWS key pair"
  type        = string
}

variable "aws_ssh_key_content" {
  description = "Content of private key (PEM)"
  type        = string
  sensitive   = true
}