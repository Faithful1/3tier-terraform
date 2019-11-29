output "alb_target_group_arn" {
  value = "${aws_alb_target_group.app_target_group.id}"
}

output "alb_security_group" {
  value = "${aws_security_group.app_alb_sg.id}"
}
