# API gateway
resource "aws_instance" "kafka" {
  subnet_id     = aws_subnet.public.id
  ami           = local.EC2InstaceAMI
  instance_type = "t2.small"
#   user_data = <<-EOF
#               #!/bin/bash
#               echo "Hello, World" > index.html
#               python3 -m http.server 8080 &
#               EOF
   tags = {
     Name = "kafka"
   }
    vpc_security_group_ids =  [aws_security_group.allow_internet_traffic.id, aws_security_group.allow_ssh.id, aws_security_group.kafka_sg.id]
    key_name = "ansible-key"
}

# Security Group for resources that want to access kafka 
resource "aws_security_group" "kafka_access_sg" {
  vpc_id      = aws_vpc.store-vpc.id
  name        = "kafka-access-sg"
  description = "Allow access to kafka"

  tags =  {
    Name        = "kafka-access-sg"
  }
}

resource "aws_security_group" "kafka_sg" {
  name = "kafka-sg"
  description = " Kafka Security Group"
  vpc_id = aws_vpc.store-vpc.id
  
 

  //allow  inbound  traffic at 9092 from sources associated with security group kafka_access_sg
  ingress {
      from_port = 9092
      to_port   = 9092
      protocol  = "tcp"
      security_groups = ["${aws_security_group.kafka_access_sg.id}"]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name        = "kafka-access-sg"
  }
}