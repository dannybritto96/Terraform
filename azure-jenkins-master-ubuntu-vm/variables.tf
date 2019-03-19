variable "artifactsLocation" {
  default = "https://mprpdfartifactstore.azureedge.net/publicartifacts/azure-oss.jenkins-f28cb13a-fbc8-49e2-b63a-a23d1c74710f-jenkins/Artifacts"
}

variable "artifactsSasToken" {
  default     = ""
  description = "SAS token for Artifacts (if required)"
}

variable "extensionScript" {
  default = "install_jenkins.sh"
}

variable "adminPassword" {
  description = "Password for Admin account in VM"
}

variable "adminUsername" {
  description = "Admin Username"
}

variable "dnsprefix" {
  description = "DNS Prefix for Jenkins"
}

variable "enableCloudAgents" {
  default     = "aci"
  description = "Whether add a default cloud template for agents"
}

variable "spId" {
  default     = ""
  description = "The Service Principal Id"
}

variable "spSecret" {
  default     = ""
  description = "The Service Principal secret"
}

variable "jenkinsReleaseType" {
  default     = "LTS"
  description = "Jenkins release type (LTS or weekly or verified)"
}

variable "jdkType" {
  default     = "zulu"
  description = "JDK type (zulu or openjdk)"
}

variable "location" {
  description = "Location of Resource Group"
}

variable "resourceGroupName" {
  description = "Name of resource group"
}

variable "publicIpName" {
  default     = "jenkins-pip"
  description = "Public IP name"
}

variable "domainNameLabel" {
  description = "Domain Name Label"
}

variable "StorageAccountType" {
  default     = "Standard_LRS"
  description = "Storage Account Type"
}

variable "vmName" {
  description = "Virtual Machine Name (also used as a prefix for other resources)"
}

variable "vmSize" {
  default     = "Standard_DS1_v2"
  description = "Virtual Machine Size"
}

variable "vnetName" {
  default     = "jenkins-vnet"
  description = "Name of the Virtual Network (VNET)"
}

variable "vnetAddressPrefix" {
  default     = "172.16.0.0/16"
  description = "Virtual network address CIDR"
}

variable "subnetName" {
  default     = "jenkins"
  description = "Name of the subnet"
}

variable "subnetCIDR" {
  default     = "172.16.0.0/24"
  description = "subnet CIDR"
}

variable "ubuntuSku" {
  default = "16.04-LTS"
}

variable "spType" {
  default     = "msi"
  description = "The type of service principal injected into Jenkins (can be 'msi' or 'manual')."
}
