variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
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


variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}


variable "lambda_name" {
  description = "Base name for Lambda function"
  type        = string
  default     = "snapshot-cleanup"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 300
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
}

