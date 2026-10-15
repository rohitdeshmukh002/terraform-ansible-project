output "control_public_ip" {
  value = aws_instance.control.public_ip
}

output "managed_public_ips" {
  value = aws_instance.managed[*].public_ip
}

output "managed_private_ips" {
  value = aws_instance.managed[*].private_ip
}

output "ansible_control_ssh" {
  description = "SSH command for the Ansible control instance"
  value       = "ssh -i <private-key-path> ubuntu@${aws_instance.control.public_ip}"
}