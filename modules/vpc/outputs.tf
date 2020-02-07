output "vpc-id" {
  value = aws_vpc.terraform-vpc.id
}
output "pri-subnet-id" {
  value = aws_subnet.private-subnet.id
}
output "pub-subnet-id" {
  value = aws_subnet.public-subnet.id
}
output "pub-subnet-id2" {
  value = aws_subnet.public-subnet2.id
}

output "public-SG" {
  value = aws_security_group.Public-Security-Group.id
}
output "LB-SG" {
  value = aws_security_group.LB-Security-Group.id
}




output "private-SG" {
  value = aws_security_group.Private-Security-Group.id
}

output "iam_instance_profile_id" {
  value = aws_iam_instance_profile.my-instance-profile.id
}

