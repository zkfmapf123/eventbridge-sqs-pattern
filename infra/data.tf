data "aws_caller_identity" "blue_currnt" {}
data "aws_caller_identity" "main_current" {}

output "blue" {
  value = data.aws_caller_identity.blue_currnt
}

output "main" {
  value = data.aws_caller_identity.main_current
}
