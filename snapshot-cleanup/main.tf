
provider "aws" {
  region = var.aws_region
}

# VPC Module - Creates VPC, subnets, and networking components
module "vpc" {
  source = "./modules/vpc"
  aws_region = var.aws_region
}

# IAM Module - Creates IAM role and policies for Lambda
module "iam" {
  source = "./modules/iam"
}

# Package Lambda code
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/lambda_function.py"
  output_path = "${path.module}/lambda_function.zip"
}

# Lambda Function
resource "aws_lambda_function" "snapshot_cleanup" {
  filename         = "lambda_function.zip"
  function_name    = "snapshot_cleanup_function"
  role             = module.iam.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  timeout          = 60
  
  vpc_config {
    subnet_ids         = [module.vpc.private_subnet_id]
    security_group_ids = [module.vpc.lambda_sg_id]
  }

  tags = {
    Name        = var.lambda_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "EC2 Snapshot Cleanup"
  }

  depends_on = [
    module.vpc,
    module.iam
  ]
}

# CloudWatch EventBridge Rule - Daily trigger
resource "aws_cloudwatch_event_rule" "daily_trigger" {
  name                = "${var.lambda_name}-daily-trigger"
  description         = "Trigger snapshot cleanup Lambda daily at midnight"
  schedule_expression = "rate(1 day)"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.daily_trigger.name
  target_id = "snapshot-cleanup"
  arn       = aws_lambda_function.snapshot_cleanup.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.snapshot_cleanup.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.daily_trigger.arn
}
