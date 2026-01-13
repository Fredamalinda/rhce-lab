# modules/networking/outputs.tf

output "vpc_id" {
  value = aws_vpc.lab_vpc.id
}

output "subnet_id" {
  value = aws_subnet.lab_subnet.id
}

output "security_group_id" {
  value = aws_security_group.lab_sg.id
}