variable "region" {
  default = "us-east-1"
  description = "Region"
}

variable "privateSubnetName" {
  default = "private"
  description = "Name of private subnet"
}

variable "publicSubnetName" {
  default = "public"
  description = "Name of public subnet"
}

variable "privateCIDR" {
  default = "10.0.1.0/24"
  description = "CIDR Block for Private Subnet"
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

variable "nat_gw" {
  default = "my_nat"
  description = "NAT Gateway"
}

variable "route_table" {
  default = "Public Route Table"
  description = "Name of public route table"
}

variable "instance_type" {
  default = "t2.micro"
  description = "Instance Type"
}

variable "db_port" {
  default = 27017
  description = "Database connection port"
}

variable "key_pair" {
  default = "mykey"
  description = "Key Pair Name" //Existing
}





