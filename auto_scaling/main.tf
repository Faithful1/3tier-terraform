resource "aws_launch_configuration" "app_launch_config" {
  image_id        = var.ami
  instance_type   = var.instance_type
  security_groups = ["${aws_security_group.app_asg_sg.id}"]
  user_data       = data.template_file.init.rendered

  /* user_data = <<-EOF
            #!/bin/bash
            yum -y install httpd
            echo "Hello, from Terraform" > /var/www/html/index.html
            service httpd start
            chkconfig httpd on
            EOF
*/

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}

resource "aws_autoscaling_group" "app_autoscaling_group" {
  launch_configuration = "${aws_launch_configuration.app_launch_config.name}"
  vpc_zone_identifier  = ["${split(",", var.subnet_id)}"]
  target_group_arns    = ["${var.target_group_arn}"]
  health_check_type    = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key                 = "Name"
    value               = "my-test-asg"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "app_asg_sg" {
  name   = "genesis-asg-sg"
  vpc_id = "${var.vpc_id}"
}

resource "aws_security_group_rule" "inbound_ssh" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.app_asg_sg.id}"
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "inbound_http" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.app_asg_sg.id}"
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "outbound_all" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = "${aws_security_group.app_asg_sg.id}"
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


