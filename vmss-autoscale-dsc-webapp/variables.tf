variable "resource_group_name" {
    description = "The name of the resource group  in which the VMSS should be created."
}

variable "location" {
    description = "Location of resource group"
}

variable "vm_sku" {
    description = "Size of VMs in the VM Scale Set."
}

variable "vmss_name" {
    description = "Scale set name"
}

variable "instance_count" {
    description = "Number of VM instances (100 or less)."
}

variable "admin_username" {
    description = "Admin username on all VMs."
}

variable "admin_password" {
    description = "Admin password on all VMs."
}

variable "image_publisher" {
    description = "The name of the publisher of the image (az vm image list)"
    default     = "MicrosoftWindowsServer"
}

variable "image_offer" {
    default = "WindowsServer"
}

variable "windowsOSVersion" {
    description = "The Windows version for the VM."
    default     = "2012-R2-Datacenter"
}

variable "image_version" {
    description = "Image Version to use"
    default = "latest"
}

variable "powershellDSCzip" {
    description = "URL to DSC zip"
    default = "https://raw.githubusercontent.com/dannybritto96/Azure-Quickstart-Templates/master/DSC/IISInstall.zip"
}

variable "WebDeployPackage" {
    description = "URL to WebApp Zip"
    default = "https://raw.githubusercontent.com/dannybritto96/Azure-Quickstart-Templates/master/WebDeploy/WebApplication1.zip"
}

variable "vnet-rg" {
  description = "Existing VNET resource group"
}

variable "existing-vnet" {
    description = "Existing VNET name"
}

variable "existing-subnet" {
    description = "Existing Subnet in the mentioned VNET"
}

variable "app-gateway-resource-group" {
    description = "Resource group of App Gateway"
}

variable "app-gateway" {
    description = "Application Gateway Name"
}

variable "existing-app-gateway-backend-pool" {
    description = "The name of the Backend Pool in the existing Application Gateway that will load-balance the instances of this VM Scale Set."
}