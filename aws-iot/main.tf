provider "aws" {
  access_key = ""
  secret_key = ""
  region = "us-east-1"
}

resource "aws_iot_thing" "iot_thing" {
  name = "${var.thing_name}"
}

resource "aws_iot_certificate" "cert" {
  csr = "${file("F:\\shared\\Terraform\\aws-iot\\server.csr")}"
  active = true
}

resource "aws_iot_policy" "pubsub" {
  name = "PubSubToAnyTopic"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "iot:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iot_policy_attachment" "policy_attach" {
  policy = "${aws_iot_policy.pubsub.name}"
  target = "${aws_iot_certificate.cert.arn}"
}

resource "aws_iot_thing_principal_attachment" "att" {
  principal = "${aws_iot_certificate.cert.arn}"
  thing = "${aws_iot_thing.iot_thing.name}"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_lambda_function" "sampfunc" {
  filename = "F:\\shared\\Terraform\\aws-iot\\payload.zip"
  function_name = "${var.lambda_function_name}"
  role = "${aws_iam_role.iam_for_lambda.arn}"
  handler = "${var.lambda_handler}"
  source_code_hash = "${base64sha256(file("F:\\shared\\Terraform\\aws-iot\\payload.zip"))}"
  runtime = "python3.6"
}


resource "aws_iot_topic_rule" "rule1" {
  name = "TestRule"
  enabled = true
  sql = "SELECT * FROM 'test'"
  sql_version = "2015-10-08"
  lambda {
    function_arn = "${aws_lambda_function.sampfunc.arn}"
  }
}

