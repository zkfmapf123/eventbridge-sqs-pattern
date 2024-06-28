resource "aws_ssm_parameter" "sqs_value" {
  name  = "OTHER_ACCOUNT_SQS_URL"
  type  = "String"
  value = aws_sqs_queue.eda-sqs.url
}
