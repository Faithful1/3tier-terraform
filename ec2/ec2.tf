resource "aws_key_pair" "app_key" {
  key_name   = "genesis"
  public_key = file(var.my_public_key)
}

data "template_file" "init" {
  template = "${file("${path.module}/userdata.tpl")}"
}

resource "aws_instance" "app_front_instance" {
  count                  = 2
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.app_key.id
  vpc_security_group_ids = ["${var.app_security_group}"]
  subnet_id              = element(var.public_subnets, count.index)
  user_data              = data.template_file.init.rendered

  tags = {
    Name = "genesis-front-instance-${count.index + 1}"
  }
}

# resource "aws_ebs_volume" "app_front_instance_ebs" {
#   count             = 2
#   availability_zone = data.aws_availability_zones.var.azs[count.index]
#   size              = 1
#   type              = "gp2"
#   tags = {
#     Name = "genesis-front-ebs-${count.index + 1}"
#   }
# }

# resource "aws_volume_attachment" "app_front_vol" {
#   count        = 2
#   device_name  = "/dev/xvdh"
#   instance_id  = aws_instance.app_front_instance.*.id[count.index]
#   volume_id    = aws_ebs_volume.app_front_instance_ebs.*.id[count.index]
#   force_detach = true
#   tags = {
#     Name = "genesis-front-volume-${count.index + 1}"
#   }
# }
