output "instance_public_ip" {
  description = "Public IPv4 address assigned to the web instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the web instance"
  value       = aws_instance.web.public_dns
}