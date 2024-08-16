terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

//create vpc
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Devops VPC"
  }
}

//create subnet
resource "aws_subnet" "main-subnet" {
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 3, 1)
  vpc_id            = aws_vpc.main.id
  availability_zone = var.az
}

//create a security group
resource "aws_security_group" "allow_ssh" {
  name = "allow_ssh"
  tags = {
    Name = "Allow SSH"
  }
  vpc_id = aws_vpc.main.id
  ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
  }
}

//create igw
resource "aws_internet_gateway" "devops-gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Devops-gw"
  }
}

//create route table and associations
resource "aws_route_table" "route-table-main" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.devops-gw.id
  }
  tags = {
    Name = "devops-route-table"
  }
}


resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.main-subnet.id
  route_table_id = aws_route_table.route-table-main.id
}

//create an aws instance
resource "aws_instance" "main" {
  ami           = var.ami_id
  instance_type = var.instance_type
  tags = {
    Name = "Devops with Jenkins-SonarCube"
  }
  subnet_id       = aws_subnet.main-subnet.id
  security_groups = aws_security_group.allow_ssh.id
  user_data       = file("${path.module}/script.sh")

}

//create elastic ip
resource "aws_eip" "devops-ip" {
  instance = aws_instance.main.id
  vpc      = true
}


