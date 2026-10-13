resource "aws_key_pair" "server_key" {
  key_name   = var.key_pair_name
  public_key = file("${path.module}/terra-ansible.pub")
}

resource "aws_instance" "server-ec2" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.server_key.key_name
  subnet_id              = aws_subnet.sub_net.id
  vpc_security_group_ids = [aws_security_group.my_sg.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-server"
  }
}

resource "aws_vpc" "server-vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_name}-${var.environment}-server"
  }
}

resource "aws_security_group" "my_sg" {
  name        = "${var.project_name}-sg"
  description = "this is the security group"
  vpc_id      = aws_vpc.server-vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_subnet" "sub_net" {
  vpc_id            = aws_vpc.server-vpc.id
  availability_zone = var.availability_zone
  cidr_block        = var.subnet_cidr

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-sn"
  }

}

resource "aws_internet_gateway" "project_sg" {
  vpc_id = aws_vpc.server-vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.server-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project_sg.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.sub_net.id
  route_table_id = aws_route_table.route_table.id
}