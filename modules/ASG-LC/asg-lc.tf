resource "aws_launch_configuration" "LC" {
  name          = var.LC-name
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  security_groups = [var.pub-SG]
  iam_instance_profile = var.iam_instance_profile
  associate_public_ip_address = true
  user_data = data.template_file.userdata-LC.rendered
  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "userdata-LC" {
  template = file("/Users/apple/Desktop/terraform/Terraform-app/modules/templates/userdata-LC.tpl")
  vars = {
    private_ip_ec2 = var.private_ip_ec2
  }
}


resource "aws_autoscaling_group" "ASG" {
  name                 = var.ASG-name
  launch_configuration = aws_launch_configuration.LC.name
  min_size             = 2
  max_size             = 3
  default_cooldown = 20
  health_check_grace_period = 300
  vpc_zone_identifier  = [var.pub-subnet, var.pub-subnet2]
  lifecycle {
    create_before_destroy = true
  }
  target_group_arns = [var.TG_ARN]
  tag {
    key                 = "Name"
    value               = "Public-EC2 - ${terraform.workspace}"
    propagate_at_launch = true
  }
}