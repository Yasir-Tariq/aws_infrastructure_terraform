output "vpc_id" {
  value = aws_vpc.vpc.id
}
output "private_subnet" {
  value = aws_subnet.private_subnet.*.id
}
output "public_subnet" {
  value = aws_subnet.public_subnet.*.id
}
output "public_sg" {
  value = aws_security_group.public_sg.id
}
output "lb_sg" {
  value = aws_security_group.lb_sg.id
}
output "sg" {
  value = aws_security_group.private_sg.id
}