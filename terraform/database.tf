# user service RDS instance
resource "aws_db_instance" "userService_RDS_instance" {
  allocated_storage   = 20
  storage_type        = "gp2"
  engine              = "mysql"
  engine_version      = "5.7"
  instance_class      = "db.t2.micro"
  db_subnet_group_name   = aws_db_subnet_group.userService_rds_subnet_group.id
  # multi_az = true
  # name of the database to create when the DB instance is created
  db_name = "store"
  username            = var.userService_db_user
  password            = var.userService_db_password
  port                = "3306"
  skip_final_snapshot = true
}

/* subnet used by userService rds */
resource "aws_db_subnet_group" "userService_rds_subnet_group" {
  name        = "user-service-rds-subnet-group"
  description = "RDS subnet group for userService"
  subnet_ids  = aws_subnet.private.*.id 
}

# order service RDS instance
# resource "aws_db_instance" "orderService_RDS_instance" {
#   allocated_storage   = 20
#   storage_type        = "gp2"
#   engine              = "mysql"
#   engine_version      = "5.7"
#   instance_class      = "db.t2.micro"

#   # TF_VAR_username
#   username            = var.orderService_db_user
#   password            = var.orderService_db_password
#   name                = var.orderService_db_name
#   port                = 3306
#   skip_final_snapshot = true
# }