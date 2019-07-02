
variable "instance_az" {
  default = "us-east-1a"
  description = "Instance AZ"
}

variable "lb_az2" {
  default = "us-east-1b"
  description = "LB AZ 2"
}

variable "instance_tag" {
  default = "SERV"
  description = "Name tags of instance"
}

variable "region" {
    default = "us-east-1"
    description = "AWS Region"
}