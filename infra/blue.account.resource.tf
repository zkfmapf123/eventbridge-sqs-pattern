################################### SQS ###################################
resource "aws_sqs_queue" "eda-sqs" {
  provider = aws.blue

  name = "eda-queue"

  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10
}

resource "aws_sqs_queue_policy" "eda-sqs-policy" {
  provider = aws.blue

  queue_url = aws_sqs_queue.eda-sqs.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "${aws_sqs_queue.eda-sqs.arn}/SQSDefaultPolicy",
    "Statement" : [{
      "Sid" : "AccessToLeedonggyuAccount",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : [
          "arn:aws:iam::${data.aws_caller_identity.main_current.id}:root"
        ]
      },
      "Action" : "sqs:*",
      "Resource" : "${aws_sqs_queue.eda-sqs.arn}"
    }]
  })

  depends_on = [aws_sqs_queue.eda-sqs]
}

################################### S3 ###################################
resource "aws_s3_bucket" "s3_bucket" {
  provider = aws.blue

  bucket = "blue-account-bucket"
}

