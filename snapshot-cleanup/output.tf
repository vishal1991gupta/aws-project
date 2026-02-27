output "lambda_function_name" {
  value = aws_lambda_function.snapshot_cleanup.function_name
}



output "cloudwatch_rule_name" {
  value = aws_cloudwatch_event_rule.daily_trigger.name
}

output "lambda_role_arn" {
  value = module.iam.lambda_role_arn
}

output "lambda_role_name" {
  value = module.iam.lambda_role_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}


output "lambda_sg_id" {
  value = module.vpc.lambda_sg_id
}