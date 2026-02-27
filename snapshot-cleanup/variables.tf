variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "Development"
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


