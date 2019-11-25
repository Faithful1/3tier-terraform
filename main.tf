provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "~/.aws/credentials"
}

module "vpc" {
  source              = "./vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_rt_cidr      = "0.0.0.0/0"
  private_rt_cidr     = "0.0.0.0/0"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  # azs                 = ["ap-southeast-1a", "ap-southeast-1b"]
}

module "ec2" {
  source             = "./ec2"
  my_public_key      = "~/.ssh/id_rsa1.pub"
  instance_type      = "t2.micro"
  app_security_group = "${module.vpc.genesis_security_group}"
  public_subnets     = "${module.vpc.genesis_public_subnets}"
  ami                = "ami-02c9e57e"
}

module "alb" {
  source = "./alb"
  vpc_id = "${module.vpc.genesis_vpc_id}"

  instance1_id = "${module.ec2.instance1_id}"
  instance2_id = "${module.ec2.instance2_id}"

  public_subnet1 = "${module.vpc.public_subnet1}"
  public_subnet2 = "${module.vpc.public_subnet2}"
}
