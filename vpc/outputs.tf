output "genesis_security_group" {
  value = "${aws_security_group.app_security_group.id}"
}

output "genesis_public_subnets" {
  value = "${aws_subnet.app_public_subnets.*.id}"
}

output "genesis_vpc_id" {
  value = "${aws_vpc.app_vpc.id}"
}

output "public_subnet1" {
  value = "${element(aws_subnet.app_public_subnets.*.id, 1)}"
}

output "public_subnet2" {
  value = "${element(aws_subnet.app_public_subnets.*.id, 2)}"
}

output "private_subnet1" {
  value = "${element(aws_subnet.app_private_subnets.*.id, 1)}"
}

output "private_subnet2" {
  value = "${element(aws_subnet.app_private_subnets.*.id, 2)}"
}
