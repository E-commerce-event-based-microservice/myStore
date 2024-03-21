# input variables, can be passed during applying the apply command
variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "ExampleAppServerInstance"
}

locals{
    APIGatewayPort = 8080
    NotificationTopicName = "OrderCreated"
    orderTopicName = "orderRecieved"
    # Ubuntu 20.04 LTS // us-east-1
    EC2InstaceAMI = "ami-011899242bb902164" 
    EC2InstanceType = "t2.micro"
}

#  user service database  related
# at least password will be supplied as env variable
variable "userService_db_user" {
  description = "user service database user"
  type        = string
  default     = "root"
}
variable "userService_db_password" {
  description = "user service database password"
  type        = string
}
variable "userService_db_name" {
  description = "name of the database"
  type        = string
  default     = "userDB"
}
variable "userService_db_host" {
  description = "IP of the database"
  type        = string
  default     = "localhost"
}

#  user service database  related
variable "orderService_db_user" {
  description = "user service database user"
  type        = string
  default     = "root"
}
variable "orderService_db_password" {
  description = "user service database password"
  type        = string
}
variable "orderService_db_name" {
  description = "name of the database"
  type        = string
  default     = "orderDB"
}

variable "orderService_db_host" {
  description = "IP of the database"
  type        = string
  default     = "localhost"
}
# networking related
variable "public_subnet" {
  description = "the public subnet that includes the API gateway"
  default = "10.0.1.0/24"
}

variable "private_subnets" {
  description = "List of private subnets"
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default = ["us-east-1a", "us-east-1b"]
}

variable "aws_region" {
  description = "aws region of deployed app"
  default = "us-east-1"
}

variable "SSH_key" {
  description = "key to access API gateway and kafka and provisione files"



}
#env 
# variable "APIG_dns"{
#   description = "dns of API gateway "
# }

#env 
# variable "userService_rds_dns"{
#   description = "dns of userService dns"
# }