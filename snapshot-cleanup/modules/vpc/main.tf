resource "aws_vpc" "lambda_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.lambda_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone
}

resource "aws_security_group" "lambda_sg" {
  name   = "lambda-sg"
  vpc_id = aws_vpc.lambda_vpc.id
   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# VPC Endpoint for EC2 API (to avoid NAT Gateway)
resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = aws_vpc.lambda_vpc.id
  service_name      = "com.amazonaws.${var.aws_region}.ec2"
  vpc_endpoint_type = "Interface"
  
  subnet_ids = [aws_subnet.private_subnet.id]
  
  security_group_ids = [aws_security_group.lambda_sg.id]
  
  private_dns_enabled = true
  
  tags = {
    Name = "ec2-vpc-endpoint"
  }
}

# Outputs
output "vpc_id" {
  value = aws_vpc.lambda_vpc.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}


output "lambda_sg_id" {
  value = aws_security_group.lambda_sg.id
}