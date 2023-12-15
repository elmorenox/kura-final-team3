variable "access_key" {
  description = "AWS access key"
  type        = string
}

variable "secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "east_vpc_id" {
  description = "VPC ID of the east VPC"
  type        = string
}

variable "peer_vpc_id" {
  description = "VPC ID of the peer VPC"
  type        = string
}

variable "peer_vpc_cidr" {
  description = "CIDR block of the peer subnet"
  type        = string
}

variable "east_vpc_cidr" {
  description = "CIDR block of the east VPC"
  type        = string
}

variable "peer_route_table_id" {
  description = "Route table ID of the peer VPC"
  type        = string
}

variable "east_route_table_id" {
  description = "Route table ID of the east VPC"
  type        = string
  
}

variable "east_node_sg_id" {
  description = "Security group ID of the east VPC"
  type        = string
  
}

variable "peer_node_sg_id" {
  description = "Security group ID of the peer VPC"
  type        = string
  
}

