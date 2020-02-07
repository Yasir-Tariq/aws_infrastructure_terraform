resource "aws_instance" "Private-ec2" {
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  connection {
    type = "ssh"
    user = "ubuntu"
    host = self.public_ip
  }
  vpc_security_group_ids = [var.private-SG]
  subnet_id = var.pri-subnet-id
  associate_public_ip_address = false
  user_data = data.template_file.userdata.rendered
  iam_instance_profile = var.iam_instance_profile_id
  tags = {
    Name = "Private-EC2 - ${terraform.workspace}"
  }
}

data "template_file" "userdata" {
  template = file("/Users/apple/Desktop/terraform/Terraform-app/modules/templates/userdata.tpl")
}