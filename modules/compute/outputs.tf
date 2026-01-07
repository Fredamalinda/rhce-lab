# modules/compute/outputs.tf

output "control_node_public_ip" {
  value = aws_instance.control.public_ip
}

output "control_node_private_ip" {
  value = aws_instance.control.private_ip
}

output "managed_node_private_ips" {
  value = aws_instance.managed[*].private_ip
}

output "db_node_private_ip" {
  value = aws_instance.db_node.private_ip
}