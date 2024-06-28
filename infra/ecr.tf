resource "aws_ecr_repository" "ecr" {
  provider = aws.main

  name = "ed-pattern"
}
