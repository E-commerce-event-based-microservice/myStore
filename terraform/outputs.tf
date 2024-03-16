output "APIG_ip_addr" {
  value = aws_instance.APIG.public_ip
}

# output "db_instance_addr" {
#   value = aws_db_instance.userService_RDS_instance.address
# }