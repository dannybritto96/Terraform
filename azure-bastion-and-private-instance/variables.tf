variable "location" {
  default = "West US"
}

variable "rg" {
  default = "SampRG"
  description = "Resource Group Name"
}

variable "vnet_address_space" {
  default = "10.0.0.0/16"
  description = "VNET Address Space"
}

variable "subnet1_address_space" {
  default = "10.0.1.0/24"
  description = "Private Subnet Address Space"
}

variable "subnet2_address_space" {
  default = "10.0.2.0/24"
  description = "Public Subnet Address Space"
}

variable "admin_username" {
  default = "ubuntu"
  description = "Admin Username"
}

variable "admin_password" {
  default = "Password.123"
  description = "Admin Password"
}

