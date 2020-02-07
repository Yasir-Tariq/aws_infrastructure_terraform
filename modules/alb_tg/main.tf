resource "aws_lb" "alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.lb_sg]
  subnets            = var.subnet
  enable_deletion_protection = false
  tags = {
    Name = "alb - ${terraform.workspace}"
  }
}
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
resource "aws_lb_target_group" "tg" {
  name     = var.tg_name
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  target_type = "instance"
  health_check {
    path = var.health_path
    port = 80
    healthy_threshold = 2
    unhealthy_threshold = 3
    timeout = 4
    interval = 6
  }
  tags = {
    Name = "tg - ${terraform.workspace}"
  }
}
