# user service RDS instance
resource "aws_db_instance" "userService_RDS_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.user_rds_sg.id]
  # multi_az = true
  # name of the database to create when the DB instance is created
  db_name = var.userService_db_name
  username            = var.userService_db_user
  password            = var.userService_db_password
  port                = "3306"
  skip_final_snapshot = true
}

/* subnets used by userService and orderService rds */
resource "aws_db_subnet_group" "rds_subnet_group" {
  name        = "user-service-rds-subnet-group"
  description = "RDS subnet group for userService"
  subnet_ids  = aws_subnet.private.*.id 
}

#order service RDS instance
resource "aws_db_instance" "orderService_RDS_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.order_rds_sg.id]

  username            = var.orderService_db_user
  password            = var.orderService_db_password
  db_name                = var.orderService_db_name
  port                = 3306
  skip_final_snapshot = true
}

# Security Group for resources that want to access the user Database 
resource "aws_security_group" "user_db_access_sg" {
  vpc_id      = aws_vpc.store-vpc.id
  name        = "user-db-access-sg"
  description = "Allow access to RDS"

  tags =  {
    Name        = "user-db-access-sg"
  }
}

# security group of user database
resource "aws_security_group" "user_rds_sg" {
  name = "rds-sg"
  description = "Security Group"
  vpc_id = aws_vpc.store-vpc.id
  
  // allows traffic from the SG itself
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  //allow  inbound  traffic at 3306 from sources associated with security group access_sg
  ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      security_groups = ["${aws_security_group.user_db_access_sg.id}"]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name        = "user-rds-sg"
  }
}

# Security Group for resources that want to access the order Database 
resource "aws_security_group" "order_db_access_sg" {
  vpc_id      = aws_vpc.store-vpc.id
  name        = "order-db-access-sg"
  description = "Allow access to RDS"

  tags =  {
    Name        = "order-db-access-sg"
  }
}

# security group of order database
resource "aws_security_group" "order_rds_sg" {
  name = "order-rds-sg"
  description = "Security Group"
  vpc_id = aws_vpc.store-vpc.id
  
  // allows traffic from the SG itself
  ingress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      self = true
  }

  //allow  inbound  traffic at 3306 from sources associated with security group order-db-access-sg
  ingress {
      from_port = 3306
      to_port   = 3306
      protocol  = "tcp"
      security_groups = ["${aws_security_group.order_db_access_sg.id}"]
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Name        = "order-rds-sg"
  }
}