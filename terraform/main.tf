
# Security group for the Ansible control node
resource "aws_security_group" "control_sg" {
  name        = "${var.project_name}-control-sg"
  description = "Allow SSH from my IP to Ansible control node"
  vpc_id      = aws_vpc.server-vpc.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Security group for managed nodes
resource "aws_security_group" "managed_sg" {
  name        = "${var.project_name}-managed-sg"
  description = "Allow SSH from Ansible control node and HTTP"
  vpc_id      = aws_vpc.server-vpc.id

  ingress {
    description     = "SSH from control node"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.control_sg.id]
  }

  ingress {
    description = "Public HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "server_key" {
  key_name   = var.key_pair_name
  public_key = file(var.public_key_path)
}

resource "aws_iam_role" "ansible_control" {
  name = "${var.project_name}-${var.environment}-ansible-control"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "ansible_control" {
  name = "${var.project_name}-${var.environment}-ansible-control"
  role = aws_iam_role.ansible_control.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["secretsmanager:GetSecretValue"]
        Effect   = "Allow"
        Resource = var.ansible_ssh_secret_arn
      },
      {
        Action   = ["ec2:DescribeInstances"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ansible_control" {
  name = "${var.project_name}-${var.environment}-ansible-control"
  role = aws_iam_role.ansible_control.name
}

# Ansible control node
resource "aws_instance" "control" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.server_key.key_name
  subnet_id                   = aws_subnet.sub_net.id
  vpc_security_group_ids      = [aws_security_group.control_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ansible_control.name
  user_data = templatefile("${path.module}/control-user-data.sh.tftpl", {
    aws_region             = var.aws_region
    ansible_ssh_secret_arn = var.ansible_ssh_secret_arn
  })
  user_data_replace_on_change = true

  tags = {
    Name = "${var.project_name}-${var.environment}-control"
    Role = "ansible-control"
  }
}

# Two managed nodes
resource "aws_instance" "managed" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.server_key.key_name
  subnet_id                   = aws_subnet.sub_net.id
  vpc_security_group_ids      = [aws_security_group.managed_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "${var.project_name}-${var.environment}-managed-${count.index + 1}"
    Role = "ansible-managed"
  }
}

resource "aws_vpc" "server-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "sub_net" {
  vpc_id                  = aws_vpc.server-vpc.id
  availability_zone       = var.availability_zone
  cidr_block              = var.subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-subnet"
  }
}

resource "aws_internet_gateway" "project_igw" {
  vpc_id = aws_vpc.server-vpc.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.server-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_igw.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public"
  }
}

resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.sub_net.id
  route_table_id = aws_route_table.public.id
}
