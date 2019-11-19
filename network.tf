#provision vpc, igw, subnets and default route-table
#1 VPC - 3 subnets (public, web , database)

# vpc
resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
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

# Subnets : public
resource "aws_subnet" "app_public_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = element(var.public_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "genesis-public-subnet-${count.index + 1}"
  }
}

# Subnets : private
resource "aws_subnet" "app_private_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = element(var.private_subnet_cidr, count.index)
  availability_zone = element(var.azs, count.index)
  tags = {
    Name = "genesis-private-subnet-${count.index + 1}"
  }
}

# Route table: public to attach Internet Gateway 
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
    cidr_block = var.public_rt_cidr
    gateway_id = aws_internet_gateway.app_gw.id
  }
  tags = {
    Name = "genesis-private-rt"
  }
}

# Route table association: attach with public subnets
resource "aws_route_table_association" "app_rt_as_public" {
  count          = length(var.public_subnet_cidr)
  subnet_id      = element(aws_subnet.app_public_subnets.*.id, count.index)
  route_table_id = aws_route_table.app_public_rt.id
}


# Route table association:  with private subnets
resource "aws_route_table_association" "app_rt_as_private" {
  count          = length(var.private_subnet_cidr)
  subnet_id      = element(aws_subnet.app_private_subnets.*.id, count.index)
  route_table_id = aws_route_table.app_private_rt.id
}
