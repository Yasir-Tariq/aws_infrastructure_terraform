resource "aws_vpc" "vpc" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "vpc - ${terraform.workspace}"
  }
}
resource "aws_subnet" "public_subnet" {
  count = length(var.az)
  vpc_id     = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone = var.az[count.index]
  cidr_block = cidrsubnet(
    signum(length(var.vpc_cidr)) == 1 ? var.vpc_cidr : "10.0.0.0/16",
    ceil(log(length(var.az) * 2, 2)),
    length(var.az) + count.index
  )

  tags = {
    Name = "public_subnet - ${terraform.workspace} - ${count.index}"
  }
}
resource "aws_subnet" "private_subnet" {
  count = 1
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private_cidr
  map_public_ip_on_launch = false
  availability_zone = var.az[count.index]

  tags = {
    Name = "private_subnet - ${terraform.workspace}"
  }
}
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw - ${terraform.workspace}"
  }
}
resource "aws_route_table" "public_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "public_table - ${terraform.workspace}"
  }
}
resource "aws_route" "public_route" {
  route_table_id            = aws_route_table.public_table.id
  destination_cidr_block    = "0.0.0.0/0"
  depends_on                = [aws_route_table.public_table]
  gateway_id = aws_internet_gateway.internet_gateway.id
}
resource "aws_route_table_association" "public_assosiation" {
  count = length(var.az)
  subnet_id      = aws_subnet.public_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_table.id
}
resource "aws_route_table" "private_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "private_table - ${terraform.workspace}"
  }
}
resource "aws_route" "private_Route" {
  route_table_id            = aws_route_table.private_table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat.id
  depends_on                = [aws_route_table.private_table]
}
resource "aws_route_table_association" "private_assosiation" {
  count = 1
  subnet_id      = aws_subnet.private_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_table.id
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet.*.id[0]
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "nat - ${terraform.workspace}"
  }
}
resource "aws_eip" "eip" {
  vpc      = true
}
resource "aws_security_group" "public_sg" {
  name        = "public-sg - ${terraform.workspace}"
  description = "Enable http and ssh for public instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    # for ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    # for http
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public_sg - ${terraform.workspace}"
  }
}
resource "aws_security_group" "lb_sg" {
  name        = "lb_sg - ${terraform.workspace}"
  description = "Load Balancer Security Group"
  vpc_id      = aws_vpc.vpc.id
  ingress {
    # for http
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lb_sg - ${terraform.workspace}"
  }
}
resource "aws_security_group" "private_sg" {
  name        = "private_sg - ${terraform.workspace}"
  description = "Enable mysql and ssh for private instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    # for ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  ingress {
    # for mysql
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "private_sg - ${terraform.workspace}"
  }
}


