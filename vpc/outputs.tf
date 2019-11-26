output "genesis_public_subnets" {
  value = "${aws_subnet.app_public_subnet.*.id}"
}

output "genesis_private_subnets" {
  value = "${aws_subnet.app_private_subnet.*.id}"
}

output "genesis_security_group" {
  value = "${aws_security_group.app_security_group.id}"
}

output "genesis_vpc_id" {
  value = "${aws_vpc.app_vpc.id}"
}

output "public_subnet1" {
  value = "${element(aws_subnet.app_public_subnet.*.id, 1)}"
}

output "public_subnet2" {
  value = "${element(aws_subnet.app_public_subnet.*.id, 2)}"
}

# output "private_subnet1" {
#   value = "${element(aws_subnet.app_private_subnet.*.id, 1)}"
# }

# output "private_subnet2" {
#   value = "${element(aws_subnet.app_private_subnet.*.id, 2)}"
# }
