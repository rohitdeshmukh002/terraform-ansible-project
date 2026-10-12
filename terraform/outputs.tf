output "instance_public_ip" {
  description = "Public IPv4 address assigned to the web instance"
  value       = aws_instance.web.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the web instance"
  value       = aws_instance.web.public_dns
}

output "state_bucket_name" {
  description = "S3 bucket name used for remote Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "state_bucket_region" {
  description = "AWS region containing the Terraform state bucket"
  value       = var.aws_region
}