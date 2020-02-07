output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_subnet" {
  value = module.vpc.private_subnet
}
output "public_subnet" {
  value = module.vpc.public_subnet
}
output "public_sg" {
  value = module.vpc.public_sg
}
output "lb_sg" {
  value = module.vpc.lb_sg
}
output "sg" {
  value = module.vpc.sg
}