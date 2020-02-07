resource "aws_instance" "ec2" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
  }
  vpc_security_group_ids = [var.sg]
  subnet_id = var.private_subnet[0]
  associate_public_ip_address = false
  user_data = data.template_file.userdata.rendered
  iam_instance_profile = var.instance_profile
  tags = {
    Name = "ec2 - ${terraform.workspace}"
  }
}

data "template_file" "userdata" {
  template = file("/Users/apple/Desktop/NOTES/terraform/Terraform_Task/modules/templates/userdata.tpl")
}