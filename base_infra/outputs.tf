output "private_subnet" {
  value = module.vpc.private_subnet
}
output "public_subnet" {
  value = module.vpc.public_subnet
}
output "output_infra" {
  value = "${
    map(
      "vpc_id", "${module.vpc.vpc_id}",
      "public_sg", "${module.vpc.public_sg}",
      "lb_sg", "${module.vpc.lb_sg}",
      "sg", "${module.vpc.sg}"
    )
  }"
}