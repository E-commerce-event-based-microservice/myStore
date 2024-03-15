terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}


# API gateway
resource "aws_instance" "APIG" {
  ami           = local.EC2InstaceAMI
  instance_type = local.EC2InstanceType
   tags = {
  #  Name = var.instance_name
     Name = APIGateway
   }
}

# user service RDS instance
resource "aws_db_instance" "userService_RDS_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"

  # TF_VAR_username
  username            = var.userService_db_user
  password            = var.userService_db_password
  name                = var.userService_db_name
  port                = 3306
  skip_final_snapshot = true
}

# order service RDS instance
resource "aws_db_instance" "orderService_RDS_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"

  # TF_VAR_username
  username            = var.orderService_db_user
  password            = var.orderService_db_password
  name                = var.orderService_db_name
  port                = 3306
  skip_final_snapshot = true
}