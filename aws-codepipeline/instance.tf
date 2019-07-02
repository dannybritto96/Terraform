resource "aws_iam_role" "instance_role" {
  name = "EC2-multirole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance_profile" {
    name = "Multirole_profile"
    role = "${aws_iam_role.instance_role.name}"
    depends_on = [
        "aws_iam_role.instance_role"
    ]
}

resource "aws_iam_role_policy" "instance_policy" {
  role = "${aws_iam_role.instance_role.name}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": [
            "codebuild:*",
            "codecommit:*",
            "codedeploy:*",
            "codepipeline:*",
            "cloudwatch:GetMetricStatistics",
            "ec2:DescribeVpcs",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "events:DeleteRule",
            "events:DescribeRule",
            "events:DisableRule",
            "events:EnableRule",
            "events:ListTargetsByRule",
            "events:ListRuleNamesByTarget",
            "events:PutRule",
            "events:PutTargets",
            "events:RemoveTargets",
            "logs:GetLogEvents"
        ],
        "Effect": "Allow",
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

}

resource "aws_default_vpc" "vpc" {

}

resource "aws_default_subnet" "subnet" {
    availability_zone = "${var.instance_az}"
}

resource "aws_security_group" "public_sg" {
  name = "Public SG"
  vpc_id = "${aws_default_vpc.vpc.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = 6
      cidr_blocks = [
          "0.0.0.0/0" 
        ]
  }

  ingress {
      from_port = 8080
      to_port = 8080
      protocol = 6
      cidr_blocks = [
        "0.0.0.0/0"
    ]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = [
        "0.0.0.0/0"
    ]
  }
}

data "aws_ami" "ubuntu" {
    most_recent = true

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"] //Ubuntu 18.04 Bionic Beaver
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    owners = ["099720109477"] //Canonical
}

resource "aws_instance" "webserv" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "t2.micro"
  subnet_id = "${aws_default_subnet.subnet.id}"
  vpc_security_group_ids = [
      "${aws_security_group.public_sg.id}"
  ]
  user_data = "${file("configure.sh")}"
  key_name = "${var.keyname}"
  iam_instance_profile = "${aws_iam_instance_profile.instance_profile.name}"
  associate_public_ip_address = true
  tags = {
    Name = "${var.instance_tag}"
  }
  depends_on = [
      "aws_iam_instance_profile.instance_profile"
  ]
}