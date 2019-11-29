output "genesis_public_subnet_1" {
  value = "${aws_subnet.app_public_subnet_1.id}"
}

output "genesis_public_subnet_2" {
  value = "${aws_subnet.app_public_subnet_2.id}"
}

output "genesis_private_subnet_1" {
  value = "${aws_subnet.app_public_subnet_1.id}"
}

output "genesis_private_subnet_2" {
  value = "${aws_subnet.app_public_subnet_2.id}"
}

output "genesis_security_group" {
  value = "${aws_security_group.app_security_group.id}"
}

output "genesis_vpc_id" {
  value = "${aws_vpc.app_vpc.id}"
}

