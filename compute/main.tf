provider "aws" {
    region = var.region
    profile = "default"
}
locals {
  private_subnet = data.terraform_remote_state.network.outputs.private_subnet
  sg = data.terraform_remote_state.network.outputs.output_infra["sg"]
  instance_profile = data.terraform_remote_state.iam.outputs.output_iam["ins_profile"]
  lb_sg = data.terraform_remote_state.network.outputs.output_infra["lb_sg"]
  subnet = data.terraform_remote_state.network.outputs.public_subnet
  vpc_id = data.terraform_remote_state.network.outputs.output_infra["vpc_id"]
  public_sg = data.terraform_remote_state.network.outputs.output_infra["public_sg"]
}
module "ec2" {
  source = "../modules/ec2"
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  private_subnet = local.private_subnet
  sg = local.sg
  instance_profile = local.instance_profile
}
module "alb_tg" {
  source = "../modules/alb_tg"
  alb_name = var.alb_name
  lb_sg = local.lb_sg
  subnet = local.subnet
  tg_name = var.tg_name
  vpc_id = local.vpc_id
  health_path = var.health_path
}
module "asg_lc" {
  source = "../modules/asg_lc"
  lc_name = var.lc_name
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  public_sg = local.public_sg
  instance_profile = local.instance_profile
  asg_name = var.asg_name
  subnet = local.subnet
  tg_arn = module.alb_tg.tg_arn
  local_ip = module.ec2.local_ip
}