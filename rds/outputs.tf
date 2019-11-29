# output "instance" {
#   value = "${aws_instance.genesis-mysql-db.ip}"
# }

output "rds" {
  value = "${aws_db_instance.app_mysql_db.endpoint}"
}
