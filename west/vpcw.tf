provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-west-1"
}
################### VPC #######################
resource "aws_vpc" "d10_vpcW" {
  cidr_block = "172.0.0.0/16"
    
    tags = {
    "Name" = "D10VPCW"
  }
}
################## IGWW #######################
resource "aws_internet_gateway" "igwW" {
  vpc_id = aws_vpc.d10_vpcW.id
}
################## NGWW #######################
resource "aws_nat_gateway" "ngwW" {
  subnet_id     = aws_subnet.public_aW.id
  allocation_id = aws_eip.elastic-ip.id
}
################# EIP ########################
resource "aws_eip" "elastic-ip" {
  domain = "vpc"
  
}
############### SUBNETS #################### 
resource "aws_subnet" "public_aW" {
  vpc_id            = aws_vpc.d10_vpcW.id
  cidr_block        = "172.0.1.0/24"
  availability_zone = "us-west-1a"
  map_public_ip_on_launch = "true"

  tags = {
    "Name" = "d10_public | us-west-1a"
    "kubernetes.io/role/elb" = "1"

  }
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.d10_vpcW.id
  cidr_block        = "172.0.2.0/24"
  availability_zone = "us-west-1c"
  map_public_ip_on_launch = "true"


  tags = {
    "Name" = "d10_public | us-west-1c"
    "kubernetes.io/role/elb" = "1"

  }
}

resource "aws_subnet" "privateW_a" {
  vpc_id            = aws_vpc.d10_vpcW.id
  cidr_block        = "172.0.3.0/24"
  availability_zone = "us-west-1a"

  tags = {
    "Name" = "d10_privateW | us-west-1a"
  }
}

resource "aws_subnet" "privateW_b" {
  vpc_id            = aws_vpc.d10_vpcW.id
  cidr_block        = "172.0.4.0/24"
  availability_zone = "us-west-1c"

  tags = {
    "Name" = "d10_privateW | us-west-1c"
  }
}
############### ROUTE TABLE ################
resource "aws_route_table" "publicW" {
  vpc_id = aws_vpc.d10_vpcW.id
}

resource "aws_route_table" "privateW" {
  vpc_id = aws_vpc.d10_vpcW.id
}

############# Routes #########################
resource "aws_route" "igwW_route" {
  route_table_id         = aws_route_table.publicW.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igwW.id
}

resource "aws_route" "privateW_ngwW" {
  route_table_id         = aws_route_table.privateW.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngwW.id
}
############ Association #######################
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public_aW.id
  route_table_id = aws_route_table.publicW.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.publicW.id
}

resource "aws_route_table_association" "privateW1" {
  subnet_id      = aws_subnet.privateW_a.id
  route_table_id = aws_route_table.privateW.id
}

resource "aws_route_table_association" "privateW2" {
  subnet_id      = aws_subnet.privateW_b.id
  route_table_id = aws_route_table.privateW.id
}

################### OUTPUT #######################
output "subnet_id_public_aW" {
  value = aws_subnet.public_aW.id
}

output "subnet_id_public_b" {
  value = aws_subnet.public_b.id
}

output "subnet_id_privateW_a" {
  value = aws_subnet.privateW_a.id
  
}
output "subnet_id_privateW_b" {
  value = aws_subnet.privateW_b.id
  
}
