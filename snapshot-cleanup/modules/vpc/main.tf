resource "aws_vpc" "lambda_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.lambda_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${aws_region}a"
}

resource "aws_security_group" "lambda_sg" {
  name   = "lambda-sg"
  vpc_id = aws_vpc.lambda_vpc.id
}

# Outputs
output "vpc_id" {
  value = aws_vpc.lambda_vpc.id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnet[*].id
}


output "lambda_security_group_id" {
  value = aws_security_group.lambda_sg.id
}