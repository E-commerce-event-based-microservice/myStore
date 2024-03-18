
locals{
     userServiceContainerPort = 8081
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
  memory             = 256
  container_definitions = jsonencode([{
    name         = "userService-API",
    # image        = "${aws_ecr_repository.app.repository_url}:latest",
    image        = "abood1/user_service",
    essential    = true,
    portMappings = [{ containerPort = local.userServiceContainerPort, hostPort = 80 }],
    
  }])
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
# resource "aws_iam_role_policy_attachment" "ecs_exec_role_policy" {
#   role       = aws_iam_role.ecs_exec_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }

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
  # family:revision
  task_definition      = "${aws_ecs_task_definition.userService.family}: ${aws_ecs_task_definition.userService.revision}"
  launch_type          = "FARGATE"
  scheduling_strategy  = "REPLICA"
  desired_count        = 2
  force_new_deployment = true

  network_configuration {
    subnets          = aws_subnet.private.*.id
    assign_public_ip = false
    security_groups = [
    #   aws_security_group.service_security_group.id,
      aws_security_group.load_balancer_security_group.id
    ]
  }

   # associate a service with target group 
  load_balancer {
    target_group_arn = aws_lb_target_group.userService_target_group.arn
    # Name of the container to associate with the load balancer (as it appears in a container definition)
    container_name   = "userService-API"
    container_port   = 8081
  }

  depends_on = [aws_alb_listener.listener]
}

# load balancer
resource "aws_alb" "application_load_balancer" {
  name               = "store-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = aws_subnet.private.*.id
  security_groups    = [aws_security_group.load_balancer_security_group.id]

  tags = {
    Name        = "store-alb"
    # Environment = var.app_environment
  }
}
# load balancer security group
# later I should change the rules to only accept ingress from the API gateway
resource "aws_security_group" "load_balancer_security_group" {
  vpc_id = aws_vpc.store-vpc.id

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "store-lb-sg"
  }
}

# load balancer  userService target group 
resource "aws_lb_target_group" "userService_target_group" {
  name        = "store-lb-userService-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.store-vpc.id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

  tags = {
    Name        = "store-lb-userService-tg"
    
}
}

# load balancer listener
resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.userService_target_group.id
  }
}

resource "aws_lb_listener_rule" "userService_path" {
  listener_arn = aws_alb_listener.listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.userService_target_group.id
  }

  condition {
    path_pattern {
      values = ["/users/*"]
    }
  }

}
