output "lambda_function_name" {
  value = aws_lambda_function.snapshot_cleanup.function_name
}



output "cloudwatch_rule_name" {
  value = aws_cloudwatch_event_rule.daily_trigger.name
}