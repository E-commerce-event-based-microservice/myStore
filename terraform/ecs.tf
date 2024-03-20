
locals{
     userServiceContainerName = "userService"
     userServiceContainerPort = 80
     userServiceImageURI = "docker.io/abood1/user_service:1.0"
    #  kafkaServiceContainerName = "kafka"
    #  kafkaServiceContainerPort = 9090
    #  kafkaServiceKafkaImageURI = "docker.io/confluentinc/cp-kafka:latest"
    #  kafkaServiceZookeeperImageURI = "docker.io/confluentinc/cp-zookeeper:latest"

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


resource "aws_ecs_cluster" "store-fargate-cluster" {
  name = "store-fargate-cluster"
  tags = {
    Name        = "store-fargate-cluster"
  }
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
    security_groups = [ aws_security_group.load_balancer_security_group.id, aws_security_group.db_access_sg.id, aws_security_group.kafka_access_sg.id ]
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


# Roles required to have access ECR, Cloud Watch, etc.
data "aws_iam_policy_document" "ecs_task_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name_prefix        = "store-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
}

resource "aws_iam_role" "ecs_exec_role" {
  name_prefix        = "store-ecs-exec-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_doc.json
 
}
# here we are attaching a policy to a role: AmazonECSTaskExecutionRolePolicy to store-ec-task-role
# this policy for logging
resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
  role       = aws_iam_role.ecs_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


resource "aws_cloudwatch_log_group" "log-group" {
  name = "store-logs"

  tags = {
    Application = "store"
  }
}


# KafkaServie
# resource "aws_ecs_service" "kafkaService" {
#   name                 = "kafkaService"
#   cluster              = aws_ecs_cluster.store-fargate-cluster.id
#   task_definition      = aws_ecs_task_definition.userService.arn
#   launch_type          = "FARGATE"
#   scheduling_strategy  = "DAEMON"
# #   deployment_minimum_healthy_percent = "50"
# #   deployment_maximum_percent = "100"      
#   force_new_deployment = true

#   network_configuration {
#     subnets          = aws_subnet.private.*.id
#     assign_public_ip = false
#     #   aws_security_group.service_security_group.id,
#     security_groups = [ aws_security_group.load_balancer_security_group.id ]
#   }

#    # associate a service with target group 
#   load_balancer {
#     target_group_arn = aws_lb_target_group.kafkaService_target_group.arn
#     # Name of the container to associate with the load balancer (as it appears in a container definition)
#     container_name   = local.userServiceContainerName
#     container_port   = local.userServiceContainerPort
#   }

#   depends_on = [aws_alb_listener.listener]
# }

# resource "aws_ecs_task_definition" "kafkaService" {
#   family             = "kafkaService"
#   # allows your Amazon ECS container task to make calls to other AWS services.
#   task_role_arn      = aws_iam_role.ecs_task_role.arn
# #ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume.
#   execution_role_arn = aws_iam_role.ecs_exec_role.arn
#   network_mode       = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#   cpu                = 256
#   memory             = 512
#   container_definitions = jsonencode([{
#     name         = "${local.kafkaServiceContainerName}",
#     image        = "${local.kafkaServiceKafkaImageURI}"
#     essential    = true,
#     portMappings = [{ containerPort = local.userServiceContainerPort, hostPort = 80 }],
#     environment = [
#       { "name":"DB_HOST", "value": "terraform-20240318222231118600000001.ctk86q0a21yb.us-east-1.rds.amazonaws.com"}
#     ],
#      "logConfiguration": {
#         "logDriver": "awslogs",
#         "options": {
#           "awslogs-group": "${aws_cloudwatch_log_group.log-group.id}",
#           "awslogs-region": "${var.aws_region}",
#           "awslogs-stream-prefix": "store"
#         }
#       },
    
#   }])
# }