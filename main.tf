terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


provider "aws" {
  region = var.region

}

#vpc

resource "aws_vpc" "example" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}


resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = var.subnet_cidr_block
  availability_zone = "${var.region}a"

  tags = {
    Name = var.subnet_name
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = var.public_subnet_cidr_block
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.subnet_name}-public"
  }
}

resource "aws_subnet" "db1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = var.db_subnet1_cidr_block
  availability_zone = "${var.region}a"

  tags = {
    Name = "db_subnet1" #var.db_subnet1_name
  }
}
resource "aws_subnet" "db2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = var.db_subnet2_cidr_block
  availability_zone = "${var.region}b"

  tags = {
    Name = "db_subnet2" #var.db_subnet2_name
  }
}


resource "aws_security_group" "example" {
  name        = var.sg_name
  description = "${var.sg_description} (terraform-managed)"
  vpc_id      = aws_vpc.example.id

  ingress {
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

resource "aws_security_group" "test_sg" {
  name = "test-test-sg"

  description = "test-test-sg (terraform-managed)"
  vpc_id      = aws_vpc.example.id

  # Only MySQL in
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.example.cidr_block, ]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.example.cidr_block, ]
  }
}

# internet gateway and Nat

resource "aws_eip" "example" {
  #domain  = "vpc"
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id

  tags = {
    Name = "test_ig"
  }
}

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.example.id
  subnet_id     = aws_subnet.public.id

  tags = {
    Name = "test_nat"
  }

  depends_on = [aws_internet_gateway.example]
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
  tags = {
    Name = "Public Subnets Route Table for My VPC"
  }
}

resource "aws_route_table_association" "example" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.example.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.example.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.example.id
  }
  tags = {
    Name = "private Subnet Route Table to NAT"
  }
}

resource "aws_route_table_association" "nat" {
  subnet_id      = aws_subnet.example.id
  route_table_id = aws_route_table.nat.id
}


resource "aws_security_group" "elb_http" {
  name        = "elb_http"
  description = "Allow HTTP traffic to instances through Elastic Load Balancer"
  vpc_id      = aws_vpc.example.id

  ingress {
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

  tags = {
    Name = "Allow HTTP through ELB Security Group"
  }
}

#database test

resource "aws_db_subnet_group" "example" {
  name       = "test_subnet_group"
  subnet_ids = [aws_subnet.db1.id, aws_subnet.db2.id]

  tags = {
    Name = "test_subnet_group"
  }
}

resource "aws_db_instance" "example" {
  identifier = "test-db"

  allocated_storage    = var.allocated_storage
  db_subnet_group_name = aws_db_subnet_group.example.id
  engine               = var.engine
  engine_version       = var.engine_version
  instance_class       = var.instance_class
  db_name              = var.db_name
  username             = var.username
  port                 = var.port
  manage_master_user_password = true
  storage_encrypted           = var.storage_encrypted
  storage_type                = var.storage_type

  vpc_security_group_ids = ["${aws_security_group.test_sg.id}"]

  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = true
}

#loadbalancers

resource "aws_elb" "example" {
  name = "test-elb"
  security_groups = [
    aws_security_group.elb_http.id
  ]
  subnets = [
    aws_subnet.public.id,
  ]

  cross_zone_load_balancing = true

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }

}
