output "control_public_ip" {
  value = aws_instance.control.public_ip
}

output "managed_public_ips" {
  value = aws_instance.managed[*].public_ip
}

output "managed_private_ips" {
  value = aws_instance.managed[*].private_ip
}