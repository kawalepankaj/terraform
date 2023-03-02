provider "aws" {
  profile = "manager"
  region  = "us-east-1"
}

/* ..................VPC................... */
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "myvpc"
  }
}

/* ....................PUBLIC SUBNET............. */
resource "aws_subnet" "public1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "true"
  tags = {
    Name = "public-subnet-2"
  }
}

/* ....................PRIVATE-SUBNET.................. */
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.myvpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = "false"
  tags = {
    Name = "private-subnet-2"
  }
}

/* ........................IGW................. */
resource "aws_internet_gateway" "myigw" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "myigw"
  }
}

/* .......................ELASTIC-IP................ */
resource "aws_eip" "myeip" {
  vpc = true
  tags = {
    Name = "myeip"
  }
}


/* ...........................NAT-GATEWAY..................... */
resource "aws_nat_gateway" "mynat_gateway" {
  allocation_id = aws_eip.myeip.id
  subnet_id     = aws_subnet.public1.id
  tags = {
    Name = "MYNAT"
  }
  depends_on = [aws_internet_gateway.myigw]
}

/* ...........................PUBLIC-ROUTE TABLE.............. */
resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myigw.id
  }
  tags = {
    Name = "public-RT"
  }
}

/* ...........................PRIVATE-ROUTE TABLE.............. */
resource "aws_route_table" "private-RT" {
  vpc_id = aws_vpc.myvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mynat_gateway.id
  }
  tags = {
    Name = "private-RT"
  }
}

/* .........................PUBLIC-SUBNET-ASSOCIATION............ */
resource "aws_route_table_association" "public-subnet-association1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public-RT.id
}
resource "aws_route_table_association" "public-subnet-association2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public-RT.id
}  

/* .........................PRIVATE-SUBNET-ASSOCIATION............ */
resource "aws_route_table_association" "private-subnet-association1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.private-RT.id
}
resource "aws_route_table_association" "private-subnet-association2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.private-RT.id
}

/* ............................EC2-INSTANCE.......................... */
resource "aws_instance" "instance-public" {
  ami                    = "ami-0557a15b87f6559cf"          
  instance_type          = "t2.micro"
  #key_name               = var.devopskey
  subnet_id      = aws_subnet.public1.id
  tags = {
    Name = "instance-public"
  }
}

resource "aws_instance" "instance-private" {
  ami                    = "ami-0557a15b87f6559cf"          
  instance_type          = "t2.micro"
  #key_name               = var.devopskey
  subnet_id      = aws_subnet.private1.id
  tags = {
    Name = "instance-private"
  }
}    