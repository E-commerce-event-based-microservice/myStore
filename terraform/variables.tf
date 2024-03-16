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
  default     = "user"
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
  default     = "order"
}

# networking related
variable "public_subnet" {
  description = "the public subnet that includes the API gateway"
}

variable "private_subnets" {
  description = "List of private subnets"
}

variable "availability_zones" {
  description = "List of availability zones"
}

