provider "aws" {
    region = var.region
    profile = "default"
  
}


module "my_vpc" {
    source = "../modules/vpc"    
    vpc-cidr = var.vpc-cidr 
    pub-cidr = var.pub-cidr
    pub-cidr2 = var.pub-cidr2
    pri-cidr = var.pri-cidr
    instance_profile = var.instance_profile
    iam_role = var.iam_role
    iam_policy =  var.iam_policy
    policy_attach = var.policy_attach
}

module "private-ec2" {
  source = "../modules/private-ec2"
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  pri-subnet-id = module.my_vpc.pri-subnet-id
  private-SG = module.my_vpc.private-SG
  iam_instance_profile_id = module.my_vpc.iam_instance_profile_id
}

module "ALB-TG" {
  source = "../modules/ALB-TG"
  ALB-name = var.ALB-name
  LB-SG = module.my_vpc.LB-SG
  pub-subnet-id = module.my_vpc.pub-subnet-id
  pub-subnet-id2 = module.my_vpc.pub-subnet-id2
  TG-name = var.TG-name
  vpc-id = module.my_vpc.vpc-id
  health-path = var.health-path
  
}

module "ASG-LC" {
  source = "../modules/ASG-LC"
  LC-name = var.LC-name
  ami = var.ami
  instance_type = var.instance_type
  key_name = var.key_name
  pub-SG = module.my_vpc.public-SG 
  iam_instance_profile = module.my_vpc.iam_instance_profile_id
  ASG-name = var.ASG-name
  pub-subnet = module.my_vpc.pub-subnet-id
  pub-subnet2 = module.my_vpc.pub-subnet-id2
  TG_ARN = module.ALB-TG.TG_ARN
  private_ip_ec2 = module.private-ec2.private_ip_ec2

}


