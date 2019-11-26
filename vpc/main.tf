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

# Query all avilable Availibility Zone
data "aws_availability_zones" "app_available" {}

# Internet Gateway
resource "aws_internet_gateway" "app_gw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "genesis-app-igw"
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


# Subnets: public
resource "aws_subnet" "app_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.app_vpc.id
  map_public_ip_on_launch = true
  cidr_block              = element(var.public_subnet_cidr, count.index)
  availability_zone       = data.aws_availability_zones.app_available.names[count.index]

  tags = {
    Name = "genesis-public-subnet-${count.index + 1}"
  }
}

# Subnets: private
resource "aws_subnet" "app_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = data.aws_availability_zones.app_available.names[count.index]

  tags = {
    Name = "genesis-private-subnet-${count.index + 1}"
  }
}


# Route table association: attach with public subnets
resource "aws_route_table_association" "app_rt_public_assoc" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.app_public_subnet.*.id, count.index)
  route_table_id = aws_route_table.app_public_rt.id
  depends_on     = [aws_route_table.app_public_rt, aws_subnet.app_public_subnet]
}

# Route table association: attach with private subnets
resource "aws_route_table_association" "app_rt_private_assoc" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.app_private_subnet.*.id, count.index)
  route_table_id = aws_route_table.app_private_rt.id
  depends_on     = [aws_route_table.app_private_rt, aws_subnet.app_private_subnet]
}

# Elastic ip: for nat gateway
resource "aws_eip" "app_eip" {
  vpc = true
}

# NAT Gateway: seats on 1 public subnet and exposes private subnets to the net
resource "aws_nat_gateway" "app_nat_gw" {
  allocation_id = aws_eip.app_eip.id
  subnet_id     = aws_subnet.app_public_subnet[0].id
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

