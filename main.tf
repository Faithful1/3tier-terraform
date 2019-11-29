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

# module "ec2" {
#   source             = "./ec2"
#   my_public_key      = "~/.ssh/id_rsa1.pub"
#   instance_type      = "t2.micro"
#   app_security_group = "${module.vpc.genesis_security_group}"
#   public_subnets     = "${module.vpc.genesis_public_subnets}"
#   ami                = "ami-02c9e57e"
# }

module "alb" {
  source         = "./alb"
  vpc_id         = "${module.vpc.genesis_vpc_id}"
  public_subnet1 = "${module.vpc.genesis_public_subnet_1}"
  public_subnet2 = "${module.vpc.genesis_public_subnet_2}"
}

module "auto_scaling" {
  source             = "./auto_scaling"
  vpc_id             = "${module.vpc.genesis_vpc_id}"
  public_subnet_1    = "${module.vpc.genesis_public_subnet_1}"
  public_subnet_2    = "${module.vpc.genesis_public_subnet_2}"
  target_group_arn   = "${module.alb.alb_target_group_arn}"
  instance_type      = "t2.micro"
  ami                = "ami-07febfdfb4080320e"
  key_name           = "jade"
  alb-security-group = "${module.alb.alb_security_group}"
}

module "rds" {
  source               = "./rds"
  db_instance          = "db.t2.micro"
  app_private_subnet_1 = "${module.vpc.genesis_private_subnet_1}"
  app_private_subnet_2 = "${module.vpc.genesis_private_subnet_2}"
  vpc_id               = "${module.vpc.genesis_vpc_id}"
  identifier           = "genesis-mysql-db"
  RDS_USERNAME         = "admin"
  RDS_PASSWORD         = "admin123"
  instance_sg          = "${module.auto_scaling.instance_security_group}"
}
