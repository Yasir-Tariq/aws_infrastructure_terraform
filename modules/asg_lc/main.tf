resource "aws_launch_configuration" "lc" {
  name          = var.lc_name
  image_id      = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  security_groups = [var.public_sg]
  iam_instance_profile = var.instance_profile
  associate_public_ip_address = true
  user_data = data.template_file.userdata_lc.rendered
  lifecycle {
    create_before_destroy = true
  }
}
data "template_file" "userdata_lc" {
  template = file("/Users/apple/Desktop/NOTES/terraform/Terraform_Task/modules/templates/userdata_lc.tpl")
  vars = {
    local_ip = var.local_ip
  }
}
resource "aws_autoscaling_group" "asg" {
  name                 = var.asg_name
  launch_configuration = aws_launch_configuration.lc.name
  min_size             = 2
  max_size             = 3
  default_cooldown = 20
  health_check_grace_period = 300
  vpc_zone_identifier  = var.subnet
  lifecycle {
    create_before_destroy = true
  }
  target_group_arns = [var.tg_arn]
  tag {
    key                 = "Name"
    value               = "public_ec2 - ${terraform.workspace}"
    propagate_at_launch = true
  }
}