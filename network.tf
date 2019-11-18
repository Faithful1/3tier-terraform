#provision vpc, igw, subnets and default route-table
#1 VPC - 3 subnets (public, web , database)

#provision app vpc
resource "aws_vpc" "app_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name     = "genesis-vpc"
    Location = "kuala-lumpur"
  }
}

# create internet gateway and attach to vpc
resource "aws_internet_gateway" "app_gw" {
  vpc_id = "${aws_vpc.app_vpc.id}"
}

# provision public subnet dynamically
resource "aws_subnet" "public_subnets" {
  count      = "${length(var.azs)}"
  vpc_id     = "${aws_vpc.app_vpc.id}"
  cidr_block = "${var.subnet_cidr}"

  tags = {
    Name = "public-subnets"
  }
}
