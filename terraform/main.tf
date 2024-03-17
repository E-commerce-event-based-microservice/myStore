terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.41.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# API gateway
resource "aws_instance" "APIG" {
  subnet_id     = aws_subnet.public.id
  ami           = local.EC2InstaceAMI
  instance_type = local.EC2InstanceType
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              python3 -m http.server 8080 &
              EOF
   tags = {
     Name = "APIGateway"
   }
    vpc_security_group_ids =  [aws_security_group.allow_internet_traffic.id, aws_security_group.allow_ssh.id]
    key_name = "ansible-key"
}

# the API gatway will be assigned to this security group
resource "aws_security_group" "allow_internet_traffic" {
  name        = "allow_http_tls"
  description = "Allow internet http and TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.store-vpc.id

  tags = {
    Name = "allow_http_tls"
  }
}

# later I will change it to port 80
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.allow_internet_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_ingress_rule" "allow_tls" {
  security_group_id = aws_security_group.allow_internet_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.allow_internet_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}


# ssh security group
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.store-vpc.id

  tags = {
    Name = "ssh-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.allow_ssh.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}