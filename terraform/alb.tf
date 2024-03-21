# load balancer
# to make it internet-facing change internal to false
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


# load balancer  orderService target group 
resource "aws_lb_target_group" "orderService_target_group" {
  name        = "store-lb-orderService-tg"
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
    Name        = "store-lb-orderService-tg"
    
}
}

# load balancer  listener
resource "aws_alb_listener" "listener" {
  load_balancer_arn = aws_alb.application_load_balancer.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.userService_target_group.id
  }
}

# userService prot 80 listerner rule
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

# orderService port 80 listener rule
resource "aws_lb_listener_rule" "orderService_path" {
  listener_arn = aws_alb_listener.listener.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.orderService_target_group.id
  }

  condition {
    path_pattern {
      values = ["/orders/*"]
    }
  }

}