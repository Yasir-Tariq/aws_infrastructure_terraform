resource "aws_vpc" "terraform-vpc" {
  cidr_block       = var.vpc-cidr
  instance_tenancy = "default"
  tags = {
    Name = "terraform-vpc - ${terraform.workspace}"
  }
}
resource "aws_subnet" "public-subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = var.pub-cidr
  map_public_ip_on_launch = true
  availability_zone = "us-east-2a"

  tags = {
    Name = "Public-Subnet - ${terraform.workspace}"
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = var.pub-cidr2
  map_public_ip_on_launch = true
  availability_zone = "us-east-2c"

  tags = {
    Name = "Public-Subnet2 - ${terraform.workspace}"
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id     = aws_vpc.terraform-vpc.id
  cidr_block = var.pri-cidr
  map_public_ip_on_launch = false
  availability_zone = "us-east-2b"

  tags = {
    Name = "Private-Subnet - ${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "Internet-Gateway" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "My-IGW - ${terraform.workspace}"
  }
}


resource "aws_route_table" "Public-Route-Table" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "Public-Route-Table - ${terraform.workspace}"
  }
}

resource "aws_route" "Public-Route" {
  route_table_id            = aws_route_table.Public-Route-Table.id
  destination_cidr_block    = "0.0.0.0/0"
  depends_on                = [aws_route_table.Public-Route-Table]
  gateway_id = aws_internet_gateway.Internet-Gateway.id
}

resource "aws_route_table_association" "Public-Subnet-Route-Table-Assosiation1" {
  subnet_id      = aws_subnet.public-subnet.id
  route_table_id = aws_route_table.Public-Route-Table.id
}
resource "aws_route_table_association" "Public-Subnet-Route-Table-Assosiation2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.Public-Route-Table.id
}

resource "aws_route_table" "Private-Route-Table" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = {
    Name = "Private-Route-Table - ${terraform.workspace}"
  }
}


resource "aws_route" "Private-Route" {
  route_table_id            = aws_route_table.Private-Route-Table.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.NAT.id
  depends_on                = [aws_route_table.Private-Route-Table]
}

resource "aws_route_table_association" "Private-Subnet-Route-Table-Assosiation" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.Private-Route-Table.id
}

resource "aws_nat_gateway" "NAT" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.public-subnet.id
  depends_on = [aws_internet_gateway.Internet-Gateway]

  tags = {
    Name = "MyNAT - ${terraform.workspace}"
  }
}

resource "aws_eip" "EIP" {
  vpc      = true
}

resource "aws_security_group" "Public-Security-Group" {
  name        = "PublicSecurityGroup"
  description = "Enable http and ssh for public instance"
  vpc_id      = aws_vpc.terraform-vpc.id

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
    Name = "Public-Security-Group - ${terraform.workspace}"
  }
}

resource "aws_security_group" "LB-Security-Group" {
  name        = "LBSecurityGroup"
  description = "Load Balancer Security Group"
  vpc_id      = aws_vpc.terraform-vpc.id
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
    Name = "LB-Security-Group - ${terraform.workspace}"
  }
}






resource "aws_security_group" "Private-Security-Group" {
  name        = "PrivateSecurityGroup"
  description = "Enable mysql and ssh for private instance"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    # for ssh
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }
  ingress {
    # for mysql
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24", "10.0.3.0/24"]
  }
  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
  

  tags = {
    Name = "Private-Security-Group - ${terraform.workspace}"
  }
}



resource "aws_iam_instance_profile" "my-instance-profile" {
  name = var.instance_profile
  role = aws_iam_role.role.name
}

resource "aws_iam_role" "role" {
  name = var.iam_role
  path = "/"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource "aws_iam_policy" "s3-policy" {
  name        = var.iam_policy
  path        = "/"
  description = "Full s3 access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Describe*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_iam_policy_attachment" "role-attach" {
  name       = var.policy_attach
  roles      = [aws_iam_role.role.name]
  policy_arn = aws_iam_policy.s3-policy.arn
}