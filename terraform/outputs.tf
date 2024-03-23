output "APIG_dns" {
  value = aws_instance.APIG.public_dns
}

output "userService_rds_dns" {
  value = aws_db_instance.userService_RDS_instance.address
}
output "kafka_dns" {
  value = aws_instance.kafka.public_dns
  }

output "alb_dns" {
  value = aws_alb.application_load_balancer.dns_name
  }