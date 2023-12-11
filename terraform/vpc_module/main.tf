provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_vpc" "redis_vpc" {
  cidr_block = "172.28.0.0/16"

  tags = {
    "Name" = "redis_vpc"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.redis_vpc.id
  cidr_block        = "172.28.0.0/18"
  availability_zone = var.az[0]
  
  tags = {
    "Name" = "${var.az[0]}-public_1"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.redis_vpc.id
  cidr_block        = "172.28.64.0/18"
  availability_zone = var.az[0]

  tags = {
    "Name" = "${var.az[0]}-private_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.redis_vpc.id
  cidr_block        = "172.28.128.0/18"
  availability_zone = var.az[1]
  
  tags = {
    "Name" = "${var.az[1]}-public_2"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.redis_vpc.id
  cidr_block        = "172.28.192.0/18"
  availability_zone = var.az[1]

  tags = {
    "Name" = "${var.az[1]}-private_2"
  }
}


output "subnet_private_2" {
  value = aws_subnet.private_subnet_2.id
}

output "subnet_private_1" {
  value = aws_subnet.private_subnet_1.id
}


resource "aws_route_table_association" "public_rt1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_rt1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public_rt2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_rt2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_eip" "elastic-ip" {
  domain = "vpc"
}

resource "aws_internet_gateway" "redis_vpc_igw" {
  vpc_id = aws_vpc.redis_vpc.id
}

resource "aws_nat_gateway" "redis_ngw" {
  subnet_id     = aws_subnet.public_subnet_1.id
  allocation_id = aws_eip.elastic-ip.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.redis_vpc.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.redis_vpc.id
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.redis_vpc_igw.id
}

resource "aws_route" "private_ngw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.redis_ngw.id
}

