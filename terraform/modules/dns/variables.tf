# modules/dns/variables.tf

variable "vpc_id" { type = string }
variable "control_node_ip" { type = string }
variable "managed_ips" { type = list(string) }
variable "db_node_ip" { type = string }