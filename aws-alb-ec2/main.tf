provider "aws" {
  region = "${var.region}"
}

resource "aws_default_vpc" "vpc" {

}

resource "aws_default_subnet" "subnet" {
    availability_zone = "${var.instance_az}"
}

resource "aws_default_subnet" "subnet2" {
    availability_zone = "${var.lb_az2}"
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
      from_port = 80
      to_port = 80
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
  associate_public_ip_address = true
  tags = {
    Name = "${var.instance_tag}"
  }
}

resource "aws_lb_target_group" "tg" {
  name = "my-targetgroup"
  port = 80
  protocol = "HTTP"
  vpc_id = "${aws_default_vpc.vpc.id}"

  health_check {
      enabled = true
      interval = 20
      path = "/health.html"
      port = 80
      protocol = "HTTP"
  }
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  target_group_arn = "${aws_lb_target_group.tg.arn}"
  target_id = "${aws_instance.webserv.id}"
  port = 80

  depends_on = [
      "aws_instance.webserv",
      "aws_lb_target_group.tg"
  ]
}

resource "aws_lb" "lb" {
  name = "my-lb"
  internal = false
  load_balancer_type = "application"
  security_groups = [
      "${aws_security_group.public_sg.id}"
  ]
  subnets = [
      "${aws_default_subnet.subnet.id}",
      "${aws_default_subnet.subnet2.id}"
  ]

  depends_on = [
      "aws_lb_target_group_attachment.tg_attachment"
  ]
}

resource "aws_lb_listener" "lb_listener" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port = 80
  protocol = "HTTP"

  default_action {
      type = "forward"
      target_group_arn = "${aws_lb_target_group.tg.arn}"
  }

  depends_on = [
      "aws_lb.lb"
  ]
}
