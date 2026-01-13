# outputs.tf

output "control_node_public_ip" {
  description = "Public IP of the Ansible Control Node"
  value       = module.compute.control_node_public_ip
}