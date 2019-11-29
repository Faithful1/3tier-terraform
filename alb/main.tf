resource "aws_alb_target_group" "app_target_group" {
  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  name        = "genesis-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_alb" "app_aws_alb" {
  name     = "genesis-app-alb"
  internal = false
  security_groups = [
    "${aws_security_group.app_alb_sg.id}",
  ]
  subnets = [
    "${var.public_subnet1}",
    "${var.public_subnet2}",
  ]
  tags = {
    Name = "genesis-test-alb"
  }
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
}

resource "aws_alb_listener" "app_test_alb_listener" {
  load_balancer_arn = aws_alb.app_aws_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_target_group.arn
  }
}

resource "aws_security_group" "app_alb_sg" {
  name        = "genesis-alb-sg"
  vpc_id      = var.vpc_id
  description = "security group for load balancer"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
