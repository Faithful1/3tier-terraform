provider "aws" {
  region                  = "ap-southeast-1"
  shared_credentials_file = "~/.aws/credentials"
}

module "vpc" {
  source              = "./vpc"
  vpc_cidr            = "10.0.0.0/16"
  public_subnet_cidr  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidr = ["10.0.3.0/24", "10.0.4.0/24"]
  public_rt_cidr      = "0.0.0.0/0"
  private_rt_cidr     = "0.0.0.0/0"
  azs                 = ["ap-southeast-1a", "ap-southeast-1b"]
}
