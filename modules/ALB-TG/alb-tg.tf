resource "aws_lb" "ALB" {
  name               = var.ALB-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.LB-SG]
  subnets            = [var.pub-subnet-id, var.pub-subnet-id2]

  enable_deletion_protection = false

  tags = {
    Name = "MyALB - ${terraform.workspace}"
  }
}


resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TG.arn
  }
}


resource "aws_lb_target_group" "TG" {
  name     = var.TG-name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc-id
  target_type = "instance"
  health_check {
    path = var.health-path
    port = 80
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 4
    interval = 6
  }
  tags = {
    Name = "MyTG - ${terraform.workspace}"
  }
}
