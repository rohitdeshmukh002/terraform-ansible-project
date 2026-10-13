output "ec2_public_ip" {
  description = "public ip"
  value       = aws_instance.server-ec2.public_ip
}

output "ec2_public_dns" {
  description = "public dns for ssh"
  value       = aws_instance.server-ec2.public_dns
}