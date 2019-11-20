# configure variables for interpolation
variable "private_rt_cidr" {}
variable "public_rt_cidr" {}
variable "vpc_cidr" {}
variable "public_subnet_cidr" {
  type = list
}
variable "private_subnet_cidr" {
  type = list
}
variable "azs" {
  type = list
}
