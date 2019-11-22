variable "my_public_key" {}

variable "instance_type" {}

variable "app_security_group" {}

variable "ami" {}

# variable "azs" {}

variable "public_subnets" {
  type = list
}
