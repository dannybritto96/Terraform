variable "region" {
  default = "us-east-1"
  description = "Region"
}

variable "publicSubnetName" {
  default = "public"
  description = "Name of public subnet"
}


variable "publicCIDR" {
  default = "10.0.2.0/24"
  description = "CIDR Block for Public Subnet"
}

variable "VPCName" {
  default = "myvpc"
  description = "Name for VPC"
}

variable "VPC_CIDR" {
  default = "10.0.0.0/16"
  description = "CIDR Block for VPC"
}

variable "igw_name" {
  default = "my_igw"
  description = "Internet Gateway"
}

variable "route_table" {
  default = "Public Route Table"
  description = "Name of public route table"
}

variable "instance_type" {
  default = "t2.micro"
  description = "Instance Type"
}

variable "key_pair" {
  default = "samp"
  description = "Key Pair Name" //Existing
}
