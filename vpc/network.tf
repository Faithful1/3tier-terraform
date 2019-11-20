#provision vpc, igw, subnets and default route-table
#1 VPC - 4 subnets (application tier, web tier, data tier)

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "genesis-app-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "app_gw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "genesis-app-igw"
  }
}

# Subnets: public
resource "aws_subnet" "app_public_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "genesis-public-subnet-${count.index + 1}"
  }
}

# Subnets: private
resource "aws_subnet" "app_private_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = "genesis-private-subnet-${count.index + 1}"
  }
}

# Route table: public to attach to Internet Gateway 
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

# Route table: private to attach to Internet Gateway 
resource "aws_route_table" "app_private_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = var.private_rt_cidr
    gateway_id = aws_internet_gateway.app_gw.id
  }

  tags = {
    Name = "genesis-private-rt"
  }
}

# Route table association: attach with public subnets
resource "aws_route_table_association" "app_rt_public_as" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.app_public_subnets.*.id, count.index)
  route_table_id = aws_route_table.app_public_rt.id
  depends_on     = [aws_route_table.app_public_rt, aws_subnet.app_public_subnets]
}

# Route table association: attach with private subnets
resource "aws_route_table_association" "app_rt_private_as" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.app_private_subnets.*.id, count.index)
  route_table_id = aws_route_table.app_private_rt.id
  depends_on     = [aws_route_table.app_private_rt, aws_subnet.app_private_subnets]
}

# Elastic ip: for nat gateway
resource "aws_eip" "app_eip" {
  vpc = true
}

# NAT Gateway: seats on 1 public subnet and exposes private subnets to the net
resource "aws_nat_gateway" "app_nat_gw" {
  allocation_id = aws_eip.app_eip.id
  subnet_id     = aws_subnet.app_public_subnets[0].id
  tags = {
    Name = "genesis-nat-gw"
  }

  depends_on = [aws_internet_gateway.app_gw]
}

# Security Group Creation
resource "aws_security_group" "app_security_group" {
  name   = "genesis-sg"
  vpc_id = aws_vpc.app_vpc.id
}

# Ingress Security Port 22
resource "aws_security_group_rule" "ssh_inbound_access" {
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.app_security_group.id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "http_inbound_access" {
  from_port         = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.app_security_group.id
  to_port           = 80
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# All OutBound Access
resource "aws_security_group_rule" "all_outbound_access" {
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.app_security_group.id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

