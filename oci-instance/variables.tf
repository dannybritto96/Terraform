variable "tenancy_ocid" {
  description = "Tenant ID"
}

variable "user_ocid" {
  description = "User OCID"
}

variable "fingerprint" {
  description = "Fingerprint of Config Public Key"
}

variable "region" {
  default = "eu-frankfurt-1"
  description = "OC Region"
}

variable "tcp_protocol" {
  default = 6
  description = "6 represents TCP"
}


variable "availability_zone" {
  default = "hwmL:EU-FRANKFURT-1-AD-1"
  description = "VM Availabilty Zone"
}

variable "instance_name" {
  default = "demoinstance"
  description = "Name of instance"
}

variable "vcn_cidr_block" {
  default = "10.0.0.0/16"
  description = "CIDR Block for VCN"
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
  description = "CIDR Block for Subnet"
}

variable "ssh_public_key" {
  description = "Contents of SSH public key"
}

variable "shape_name" {
  default = "VM.Standard2.1"
  description = "VM Shape"
}

