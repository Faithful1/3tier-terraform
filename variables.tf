# configure variables for interpolation
variable "aws_region" {
  default = "ap-southeast-1"
}
variable "aws_credentials" {
  default = "~/.aws/credentials"
}
variable "vpc_cidr" {
  default = "10.0.0.0/16"
}
variable "public_subnet_cidr" {
  type    = list
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidr" {
  type    = list
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}
variable "public_rt_cidr" {
  default = "0.0.0.0/0"
}
variable "private_rt_cidr" {
  default = "0.0.0.0/0"
}
variable "azs" {
  type    = list
  default = ["ap-southeast-1a", "ap-southeast-1b"]
}
