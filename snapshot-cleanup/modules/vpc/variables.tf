variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone for VPC subnets"
  type        = string
}


variable "private_subnet_cidr" {
  description = "Private subnet CIDR blocks"
  type        = string
}

