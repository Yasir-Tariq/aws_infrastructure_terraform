provider "aws" {
    region = var.region
    profile = "default"
}
module "vpc" {
    source = "../modules/vpc"    
    vpc_cidr = var.vpc_cidr 
    az = var.az
    private_cidr = var.private_cidr
}