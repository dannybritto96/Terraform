resource "azurerm_resource_group" "rg" {
  name = "${var.rg}"
  location = "${var.location}"
}

resource "azurerm_virtual_machine" "vm1" {
  name = "SampVM1"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic1.id}"]
  vm_size = "Standard_B1ls"
  delete_os_disk_on_termination = true

  storage_image_reference {
      publisher = "Canonical"
      offer = "UbuntuServer"
      sku = "18.04-LTS"
      version = "latest"
  }

  storage_os_disk {
      name = "mydisk1"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
  }

  os_profile {
      computer_name = "vm1"
      admin_password = "${var.admin_password}"
      admin_username = "${var.admin_username}"
  }

  os_profile_linux_config{
      disable_password_authentication = false
  }

  depends_on = [
      "azurerm_network_interface.nic1"
  ]

}

resource "azurerm_virtual_machine" "vm2" {
  name = "SampVM2"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_interface_ids = ["${azurerm_network_interface.nic2.id}"]
  vm_size = "Standard_B1ls"
  delete_os_disk_on_termination = true

  storage_image_reference {
      publisher = "Canonical"
      offer = "UbuntuServer"
      sku = "18.04-LTS"
      version = "latest"
  }

  storage_os_disk {
      name = "mydisk2"
      caching = "ReadWrite"
      create_option = "FromImage"
      managed_disk_type = "Standard_LRS"
  }

  os_profile {
      computer_name = "vm2"
      admin_password = "${var.admin_password}"
      admin_username = "${var.admin_username}"
  }

  os_profile_linux_config{
      disable_password_authentication = false
  }

  depends_on = [
      "azurerm_network_interface.nic2"
  ]

}
