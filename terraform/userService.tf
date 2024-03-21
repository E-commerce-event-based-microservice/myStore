locals{
     userServiceContainerName = "userService"
     userServiceContainerPort = 80
     userServiceImageURI = "docker.io/abood1/user_service:1.0"
}



resource "aws_ecs_task_definition" "userService" {
  family             = "userService"
  # allows your Amazon ECS container task to make calls to other AWS services.
  task_role_arn      = aws_iam_role.ecs_task_role.arn
#ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.
  execution_role_arn = aws_iam_role.ecs_exec_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                = 256
  memory             = 512
  container_definitions = jsonencode([{
    name         = local.userServiceContainerName,
    # image        = "${aws_ecr_repository.app.repository_url}:latest",
    image        = "${local.userServiceImageURI}"
    essential    = true,
    portMappings = [{ containerPort = local.userServiceContainerPort, hostPort = 80 }],
    environment = [
      { "name":"DB_HOST", "value": "${aws_db_instance.userService_RDS_instance.address}"},
      { "name":"KAFKA_HOST", "value": "${aws_instance.kafka.public_dns}"}

    ],
     "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
          "awslogs-region": "${var.aws_region}",
          "awslogs-stream-prefix": "store"
        }
      },
    depends_on = [aws_db_instance.userService_RDS_instance, aws_instance.kafka]
  }])
}


# ECS userService
resource "aws_ecs_service" "userService" {
  name                 = "userService"
  cluster              = aws_ecs_cluster.store-fargate-cluster.id
  # family:revision "${aws_ecs_task_definition.userService.family}: ${aws_ecs_task_definition.userService.revision}"
  task_definition      = aws_ecs_task_definition.userService.arn
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 2
  deployment_minimum_healthy_percent = 0
  #deployment_maximum_percent = 100     
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    #   aws_security_group.service_security_group.id,
    security_groups = [ aws_security_group.load_balancer_security_group.id, aws_security_group.order_db_access_sg.id, aws_security_group.kafka_access_sg.id ]
  }

   # associate a service with target group 
  load_balancer {
    target_group_arn = aws_lb_target_group.userService_target_group.arn
    # Name of the container to associate with the load balancer (as it appears in a container definition)
    container_name   = local.userServiceContainerName
    container_port   = local.userServiceContainerPort
  }

  depends_on = [aws_alb_listener.listener]
}
