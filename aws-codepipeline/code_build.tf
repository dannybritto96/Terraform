provider "aws" {
  region = "${var.region}"
}

data "aws_codecommit_repository" "test" {
  repository_name = "${var.reponame}"
}

resource "aws_s3_bucket" "samps3" {
  bucket = "${var.s3bucket_name}"
  acl    = "private"
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = "${aws_iam_role.codebuild_role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Resource": [
        "*"
      ],
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
    },
    {
        "Effect": "Allow",
        "Resource": [
            "${data.aws_codecommit_repository.test.arn}"
        ],
        "Action": [
            "codecommit:GitPull"
        ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterface",
        "ec2:DescribeDhcpOptions",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeVpcs"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": [
        "${aws_s3_bucket.samps3.arn}",
        "${aws_s3_bucket.samps3.arn}/*"
      ]
    }
  ]
}
POLICY

  depends_on = [
    "aws_iam_role.codebuild_role"
  ]
}

resource "aws_codebuild_project" "sample" {
    name = "${var.codebuild_project}"
    service_role = "${aws_iam_role.codebuild_role.arn}"

    artifacts {
        type = "S3"
        location = "${aws_s3_bucket.samps3.id}"
    }

    environment {
        type = "LINUX_CONTAINER"
        image = "aws/codebuild/standard:2.0"
        compute_type = "BUILD_GENERAL1_SMALL"
        image_pull_credentials_type = "CODEBUILD"
    }

    source {
        type = "CODECOMMIT"
        location = "${data.aws_codecommit_repository.test.clone_url_http}"
    }

    depends_on = [
      "aws_s3_bucket.samps3",
      "aws_iam_role_policy.codebuild_policy"
    ]
}