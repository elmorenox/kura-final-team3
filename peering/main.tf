provider "aws" {
  region = "us-west-2"
  alias  = "west"
  access_key = var.access_key
  secret_key = var.secret_key
}

provider "aws" {
  region = "us-east-1"
  alias  = "east"
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc_peering_connection" "vpc_peering" {
  provider      = aws.east
  vpc_id        = var.east_vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = "us-west-2"
  auto_accept   = false

  tags = {
    "Name" = "vpc_peering"
  }
}

resource "aws_vpc_peering_connection_accepter" "vpc_peering_accepter" {
  provider                  = aws.west
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
  auto_accept               = true
}

resource "aws_route" "east_vpc_to_peer" {
  provider                  = aws.east
  route_table_id             = var.east_route_table_id
  destination_cidr_block     = var.peer_vpc_cidr
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "peer_to_east_vpc" {
  provider                  = aws.west
  route_table_id             = var.peer_route_table_id
  destination_cidr_block     = var.east_vpc_cidr
  vpc_peering_connection_id  = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_security_group_rule" "east_sg_rule" {
  provider = aws.east
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = [var.peer_vpc_cidr]
  security_group_id = var.east_node_sg_id
}

resource "aws_security_group_rule" "peer_sg_rule" {
  provider = aws.west
  type              = "ingress"
  from_port         = 6379
  to_port           = 6379
  protocol          = "tcp"
  cidr_blocks       = [var.east_vpc_cidr]
  security_group_id = var.peer_node_sg_id
}

