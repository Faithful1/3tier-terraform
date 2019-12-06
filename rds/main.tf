# rds db instance
resource "aws_db_instance" "app_mysql_db" {
  allocated_storage       = 100 #100gb of storage gives us nire IOPS than a lower number
  engine                  = "mysql"
  engine_version          = "5.7"
  instance_class          = var.db_instance
  identifier              = var.identifier
  name                    = "genesisrds"
  multi_az                = true
  username                = var.RDS_USERNAME
  password                = var.RDS_PASSWORD
  apply_immediately       = "true"
  backup_retention_period = 30
  backup_window           = "09:46-10:16"
  db_subnet_group_name    = aws_db_subnet_group.app_rds_subnet_group.name
  vpc_security_group_ids  = ["${aws_security_group.app_rds_sg.id}"]
  skip_final_snapshot     = true
  lifecycle {
    create_before_destroy = true
  }
}

# rds db subnet group
resource "aws_db_subnet_group" "app_rds_subnet_group" {
  name        = "genesis-rds-db-subnet-group"
  description = "RDS subnet group"
  subnet_ids  = [var.app_private_subnet_1, var.app_private_subnet_2]
}

# rds security group
resource "aws_security_group" "app_rds_sg" {
  name        = "my-rds-sg"
  vpc_id      = var.vpc_id
  description = "security group for load balancer"

  # outbound Security Port 80
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound Security Port 80
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # inbound Security Port 3306
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.instance_sg]
  }
}
