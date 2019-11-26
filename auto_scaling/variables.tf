
variable "vpc_id" {}

variable "target_group_arn" {}

variable "instance_type" {}

variable "ami" {}

variable "subnet_id" {
  type = list
}
