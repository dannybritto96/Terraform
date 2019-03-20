provider "azurerm" {
  subscription_id = ""
}

data "azurerm_subscription" "subscription" {}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "res_group" {
  name     = "${var.resourceGroupName}"
  location = "${var.location}"
}

resource "azurerm_public_ip" "public_ip" {
  name                = "${var.vmName}-pip-deploy"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  domain_name_label   = "${var.domainNameLabel}"
}

resource "azurerm_virtual_network" "vnet_name" {
  name                = "${var.vnetName}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.res_group.name}"
  address_space       = ["${var.vnetAddressPrefix}"]

  subnet {
    name           = "${var.subnetName}"
    address_prefix = "${var.subnetCIDR}"
  }
}

resource "azurerm_network_security_group" "sec_group" {
  name                = "${var.vmName}-nsg"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.res_group.name}"

  security_rule {
    name                       = "ssh-rule"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http-rule"
    description                = "Allow HTTP"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 80
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "jnlp-rule"
    description                = "Allow JNLP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 5378
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

data "azurerm_subnet" "jenkins_subnet" {
  name                 = "${var.subnetName}"
  virtual_network_name = "${azurerm_virtual_network.vnet_name.name}"
  resource_group_name  = "${azurerm_resource_group.res_group.name}"
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.vmName}-nic"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.res_group.name}"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${data.azurerm_subnet.jenkins_subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.public_ip.id}"
  }

  network_security_group_id = "${azurerm_network_security_group.sec_group.id}"
}

resource "azurerm_virtual_machine" "vm" {
  name                             = "${var.vmName}"
  location                         = "${var.location}"
  resource_group_name              = "${azurerm_resource_group.res_group.name}"
  network_interface_ids            = ["${azurerm_network_interface.nic.id}"]
  vm_size                          = "${var.vmSize}"
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "${var.ubuntuSku}"
    version   = "latest"
  }

  storage_os_disk {
    name              = "mydisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "${var.StorageAccountType}"
  }

  os_profile {
    computer_name  = "jenkinsmaster"
    admin_username = "${var.adminUsername}"
    admin_password = "${var.adminPassword}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_role_assignment" "role1" {
  scope              = "${azurerm_resource_group.res_group.id}"
  principal_id       = "${data.azurerm_client_config.current.service_principal_object_id}"
  role_definition_id = "${data.azurerm_subscription.subscription.id}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
}

resource "azurerm_virtual_machine_extension" "managed_identity" {
  name                       = "ManagedIdentityExtensionForLinux"
  location                   = "${var.location}"
  resource_group_name        = "${azurerm_resource_group.res_group.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.vm.name}"
  publisher                  = "Microsoft.ManagedIdentity"
  type                       = "ManagedIdentityExtensionForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "init" {
  name                       = "Init"
  location                   = "${var.location}"
  resource_group_name        = "${azurerm_resource_group.res_group.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.vm.name}"
  auto_upgrade_minor_version = true
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"

  settings = <<SETTINGS
    {
        "fileUris": [
            "${var.artifactsLocation}/scripts/${var.extensionScript}${var.artifactsSasToken}"
        ]
    }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "[./${var.extensionScript} -ca ${var.enableCloudAgents} -jf ${azurerm_public_ip.public_ip.fqdn} -jrt ${var.jenkinsReleaseType} -jt ${var.jdkType} -lo ${var.location} -rg ${azurerm_resource_group.res_group.name} -sp ${var.spType} -subid ${data.azurerm_subscription.subscription.subscription_id} -tid {data.azurerm_client_config.current.tenant_id} -al ${var.artifactsLocation}]"
    }
  PROTECTED_SETTINGS
}
