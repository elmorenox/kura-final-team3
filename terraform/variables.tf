variable "access_key" {
  description = "aws access key"
  type        = string
}

variable "secret_key" {
  description = "aws secret key"
  type        = string
}

variable "az" {
  description = "availability zone"
  type        = string
  
}

variable "region" {
  description = "The region to deploy the VPC in"
  type        = string
}