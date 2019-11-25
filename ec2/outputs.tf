output "instance1_id" {
  value = "${element(aws_instance.app_front_instance.*.id, 1)}"
}


output "instance2_id" {
  value = "${element(aws_instance.app_front_instance.*.id, 2)}"
}


output "server_ip" {
  value = "${join(",", aws_instance.app_front_instance.*.public_ip)}"
}

/*
output "instance_id" {
  value = "${aws_instance.my-test-instance.*.id}"
}*/
