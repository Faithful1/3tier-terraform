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
