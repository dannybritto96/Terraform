variable "registries_name" {
  description = "Registry Name"
}

variable "managedClusters_name" {
  description = "Cluster Name"
}

variable "managedClusters_logAnalyticsWorkspaceResourceName" {
  description = "Resource Name of Log Analytics Workspace"
}

variable "managedClusters_logAnalyticsWorkspaceResource_RG" {
  description = "Resource group of Log Analytics Workspace"
}

variable "VNET_RG" {
  description = "Resource Group of VNET"
}

variable "VNET_name" {
  description = "VNET Name"
}

variable "subnet_name" {
  description = "Subnet Name"
}

variable "resource_group" {
  description = "Resource Group of AKS Cluster and Container Registry"
}

variable "location" {
  default = "westeurope"
  description = "Resouce Location"
}

