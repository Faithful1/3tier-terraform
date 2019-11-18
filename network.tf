#provision vpc, igw, subnets and default route-table
#1 VPC - 3 subnets (public, web , database)

# provision app vpc
resource "aws_vpc" "app_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "genesis-app-vpc"
  }
}

# create internet gateway and attach to vpc
resource "aws_internet_gateway" "app_gw" {
  vpc_id = "${aws_vpc.app_vpc.id}"
  tags = {
    Name = "genesis-app-igw"
  }
}

# provision public subnet using length function to create 2 subnets at once
# use element function to pick one element at a time for the subnet_cidr
resource "aws_subnet" "public_subnets" {
  count             = "${length(var.azs)}"
  vpc_id            = "${aws_vpc.app_vpc.id}"
  cidr_block        = "${element(var.public_subnet_cidr, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  tags = {
    Name = "genesis-public-subnet-${count.index + 1}"
  }
}

resource "aws_subnet" "private_subnets" {
  count             = "${length(var.azs)}"
  vpc_id            = "${aws_vpc.app_vpc.id}"
  cidr_block        = "${element(var.private_subnet_cidr, count.index)}"
  availability_zone = "${element(var.azs, count.index)}"
  tags = {
    Name = "genesis-private-subnet-${count.index + 1}"
  }
}
