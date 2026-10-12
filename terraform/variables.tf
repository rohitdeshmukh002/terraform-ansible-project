
variable "aws_region" {
  description = "AWS region where infrastructure will be deployed"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Deployment environment name"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t3.micro"
}

variable "project_name" {
  description = "Name of the Terraform project"
  type        = string
  default     = "terraform-ansible"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the custom VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR range for the public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "ssh_allowed_cidr" {
  description = "Public IPv4 CIDR allowed to connect over SSH"
  type        = string
}

variable "public_key_path" {
  description = "Path to the SSH public key to register with AWS"
  type        = string
}
