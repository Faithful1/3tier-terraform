resource "aws_launch_configuration" "app_launch_config" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = ["${aws_security_group.app_asg_sg.id}"]
  user_data       = "${file("${path.module}/install_apache.sh")}"
  key_name        = var.key_name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app_autoscaling_group" {
  name                 = "app_autoscaling_group"
  vpc_zone_identifier  = [var.public_subnet_1, var.public_subnet_2]
  launch_configuration = aws_launch_configuration.app_launch_config.name
  target_group_arns    = ["${var.target_group_arn}"]
  health_check_type    = "ELB"
  min_size             = 2
  max_size             = 10
  tag {
    key                 = "Name"
    value               = "genesis-test-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "app_asg_sg" {
  name        = "genesis-asg-sg"
  vpc_id      = var.vpc_id
  description = "security group for my instance"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb-security-group]
  }
}
