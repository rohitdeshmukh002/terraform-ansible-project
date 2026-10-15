variable "ami_id" {
  description = "AMI ID for the EC2 server"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the server"
  type        = string
  default     = "t3.micro"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "key_pair_name" {
  description = "Name to register for the local EC2 public key in AWS"
  type        = string
}

variable "public_key_path" {
  description = "Path to the public SSH key to register with AWS"
  type        = string
  default     = "terra-ansible.pub"
}

variable "ansible_ssh_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the matching worker SSH private key"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "terraform-ansible"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  description = "cidr subnet"
  type        = string
  default     = "10.10.0.0/24"
}

variable "availability_zone" {
  description = "aze"
  type        = string
}

variable "ssh_allowed_cidr" {
  description = "Your public IPv4 address in CIDR notation"
  type        = string
}
