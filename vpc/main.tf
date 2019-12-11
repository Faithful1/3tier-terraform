# query all avilable Availibility Zone
data "aws_availability_zones" "app_available_zones" {}

# create vpc
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "genesis-app-vpc"
  }
}

# create internet Gateway
resource "aws_internet_gateway" "app_gw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "genesis-app-igw"
  }
}

# public route table
resource "aws_route_table" "app_public_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = var.public_rt_cidr
    gateway_id = aws_internet_gateway.app_gw.id
  }
  tags = {
    Name = "genesis-public-rt"
  }
}

# private route table
resource "aws_route_table" "app_private_rt" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block     = var.private_rt_cidr
    nat_gateway_id = aws_nat_gateway.app_nat_gw.id
  }
  tags = {
    Name = "genesis-private-rt"
  }
}

# create public Subnets
resource "aws_subnet" "app_public_subnet_1" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidr[0]
  availability_zone       = data.aws_availability_zones.app_available_zones.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "genesis-public-subnet-1"
  }
}

resource "aws_subnet" "app_public_subnet_2" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.public_subnet_cidr[1]
  availability_zone       = data.aws_availability_zones.app_available_zones.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "genesis-public-subnet-2"
  }
}

# create private Subnets
resource "aws_subnet" "app_private_subnet_1" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_cidr[0]
  availability_zone = data.aws_availability_zones.app_available_zones.names[0]
  tags = {
    Name = "genesis-private-subnet-1"
  }
}

resource "aws_subnet" "app_private_subnet_2" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.private_subnet_cidr[1]
  availability_zone = data.aws_availability_zones.app_available_zones.names[1]
  tags = {
    Name = "genesis-private-subnet-2"
  }
}

# public Route table association: attach with public subnets
resource "aws_route_table_association" "app_rt_public_assoc_1" {
  subnet_id      = aws_subnet.app_public_subnet_1.id
  route_table_id = aws_route_table.app_public_rt.id
  depends_on     = [aws_route_table.app_public_rt, aws_subnet.app_public_subnet_1]
}

resource "aws_route_table_association" "app_rt_public_assoc_2" {
  subnet_id      = aws_subnet.app_public_subnet_2.id
  route_table_id = aws_route_table.app_public_rt.id
  depends_on     = [aws_route_table.app_public_rt, aws_subnet.app_public_subnet_2]
}

# private route table association: attach with private subnets
resource "aws_route_table_association" "app_rt_private_assoc_1" {
  subnet_id      = aws_subnet.app_private_subnet_1.id
  route_table_id = aws_route_table.app_private_rt.id
  depends_on     = [aws_route_table.app_private_rt, aws_subnet.app_private_subnet_1]
}

resource "aws_route_table_association" "app_rt_private_assoc_2" {
  subnet_id      = aws_subnet.app_private_subnet_2.id
  route_table_id = aws_route_table.app_private_rt.id
  depends_on     = [aws_route_table.app_private_rt, aws_subnet.app_private_subnet_2]
}

# Elastic ip: for nat gateway
resource "aws_eip" "nat_app_eip" {
  vpc = true
}

# NAT Gateway
resource "aws_nat_gateway" "app_nat_gw" {
  allocation_id = aws_eip.nat_app_eip.id
  subnet_id     = aws_subnet.app_public_subnet_1.id
  tags = {
    Name = "genesis-nat-gw"
  }
  depends_on = [aws_internet_gateway.app_gw]
}

# vpc security Group Creation
resource "aws_security_group" "app_security_group" {
  name   = "genesis-sg"
  vpc_id = aws_vpc.app_vpc.id
}

# Ingress Security Port 22
resource "aws_security_group_rule" "app_front_ssh_inbound_access" {
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.app_security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Ingress Security Port 80
resource "aws_security_group_rule" "app_front_inbound_access" {
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.app_security_group.id
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# All OutBound Access
resource "aws_security_group_rule" "app_front_all_outbound_access" {
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.app_security_group.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

