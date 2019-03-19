provider "azure_rm" {
  subscription_id = ""
}

data "azurerm_subscription" "subscription" {}

data "azurerm_client_config" "client_config" {}

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
  domain_name_label   = "${var.domainNameLabel}.${lower(replace(var.location," ",""))}.cloudapp.azure.com"
}

resource "azurem_virutal_network" "vnet_name" {
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
  virtual_network_name = "${azurem_virutal_network.vnet_name.name}"
  resource_group_name  = "${azurerm_resource_group.res_group.name}"
}

resource "azurem_network-interface" "nic" {
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
  network_interface_ids            = "${azurem_network-interface.nic.id}"
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

resource "azurem_role_assignment" "role1" {
  scope              = "${azurerm_resource_group.res_group.id}"
  principal_id       = "${data.azurerm_client_config.test.client_id}"
  role_definition_id = "Contributor"
}

resource "azurerm_virtual_machine_extension" "managed_identity" {
  name                       = "${azurerm_virtual_machine.vm.name}/ManagedIdentityExtensionForLinux"
  location                   = "${var.location}"
  resource_group_name        = "${azurerm_resource_group.res_group.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.vm.name}"
  publisher                  = "Microsoft.ManagedIdentity"
  type                       = "ManagedIdentityExtensionForLinux"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "init" {
  name                       = "${azurerm_virtual_machine.vm.name}/Init"
  location                   = "${var.location}"
  resource_group_name        = "${azurerm_resource_group.res_group.name}"
  virtual_machine_name       = "${azurerm_virtual_machine.vm.name}"
  auto_upgrade_minor_version = true
  publisher                  = "Microsoft.Azure.Extensions"
  type                       = "CustomScript"
  type_handler_version       = "2.0"

  protected_settings = <<PROTECTED_SETTINGS
    {
        "commandToExecute": "[concat('./', "${var.extensionScript}", ' -ca \"', "${var.enableCloudAgents}", '\" -jf \"', reference("${var.publicIpName}").outputs.fqdn.value, '\" -jrt \"', "${var.jenkinsReleaseType}", '\" -jt \"', "${var.jdkType}", '\" -lo \"', "${var.location}", '\" -rg \"', "${azurerm_resource_group.res_group.name}", '\" -sp \"', "${var.spType}", '\" -spid \"', "${var.spId}", '\" -ss \"', "${var.spSecret}", '\" -subid \"', "${data.azurerm_subscription.subscription.id}", '\" -tid \"', "${data.azurerm_client_config.client_config.tenant_id}", '\" -al \"', "${var.artifactsLocation}", '\" -st \"', "${var.artifactsSasToken}", '\"' )]"
    }
  PROTECTED_SETTINGS

  settings = <<SETTINGS
    {
        "fileUris": [
            "[concat("${var.artifactsLocation}", '/scripts/', "${var.extensionScript}", "${var.artifactsSasToken}")]"
        ]
    }
  SETTINGS
}
