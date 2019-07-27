provider "aws" {
    region = "${var.region}"
}

resource "aws_vpc" "vpc" {
  cidr_block = "${var.VPC_CIDR}"

  tags = {
      Name = "${var.VPCName}"
  }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.privateCIDR}"

  tags = {
      Name = "${var.privateSubnetName}"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.publicCIDR}"
  map_public_ip_on_launch = true

  tags = {
      Name = "${var.publicSubnetName}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
      Name = "${var.igw_name}"
  }
}

resource "aws_route_table" "route_table1" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
      Name = "${var.route_table}"
  }
}

resource "aws_route_table_association" "table_association" {
  subnet_id = "${aws_subnet.publicsubnet.id}"
  route_table_id = "${aws_route_table.route_table1.id}"
}

resource "aws_eip" "nat_ip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  subnet_id = "${aws_subnet.publicsubnet.id}"
  allocation_id = "${aws_eip.nat_ip.id}"
}

resource "aws_route" "private_route" {
  route_table_id = "${aws_vpc.vpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.nat.id}"
}

resource "aws_route_table_association" "table_association2" {
  subnet_id = "${aws_subnet.privatesubnet.id}"
  route_table_id = "${aws_vpc.vpc.default_route_table_id}"
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

resource "aws_security_group" "public_sg" {
  name = "Public SG"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = 6
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = 6
      cidr_blocks = ["0.0.0.0/0"]
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

resource "aws_security_group" "private_sg" {
  name = "Allow SSH"
  description = "private only"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
      from_port = 22
      to_port = 22
      protocol = 6
      cidr_blocks = ["${var.publicCIDR}"]
  }

  ingress {
      from_port = "${var.db_port}"
      to_port = "${var.db_port}"
      protocol = 6
      cidr_blocks = ["${var.publicCIDR}"]
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



resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_pair}"
  subnet_id = "${aws_subnet.publicsubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.public_sg.id}"]
  associate_public_ip_address = true

  tags {
      Name = "Bastion Server"
  }

}

resource "aws_instance" "private_instance" {
  ami = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_pair}"
  subnet_id = "${aws_subnet.privatesubnet.id}"
  vpc_security_group_ids = ["${aws_security_group.private_sg.id}"]

  tags {
      Name = "Private Instance"
  }
}

