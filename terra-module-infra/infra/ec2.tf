resource "aws_key_pair" "my_key" {
  key_name   = "${var.project_name}-key"
  public_key = file("module.pub")

  tags = {
    env = var.env
  }
}

resource "aws_vpc" "m_vpc" {
  cidr_block = var.vpc_cidr
}

resource "aws_security_group" "m_sg" {
  name        = "${var.project_name}-sg"
  description = "this is the sg"
  vpc_id      = aws_vpc.m_vpc.id

  ingress {
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = 80
    from_port   = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "var.project_name-sg"
  }
}

resource "aws_instance" "m-ec2" {
  ami             = var.ami_id
  instance_type   = var.instance_type
  key_name        = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.m_sg.id]

  tags = {
    Name = "${var.project_name}-server"
    env  = var.env
  }
}