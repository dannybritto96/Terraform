resource "azurerm_virtual_network" "vnet" {
  name = "myVNET"
  address_space = ["${var.vnet_address_space}"]
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  depends_on = [
      "azurerm_resource_group.rg"
  ]
}

resource "azurerm_subnet" "subnet1" {
  name = "PrivSubnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "${var.subnet1_address_space}"

  depends_on = [
      "azurerm_virtual_network.vnet"
  ]
}

resource "azurerm_subnet" "subnet2" {
  name = "PubSubnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix = "${var.subnet2_address_space}"

  depends_on = [
      "azurerm_virtual_network.vnet"
  ]
}

resource "azurerm_route_table" "rt1" {
  name = "RouteTable"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  disable_bgp_route_propagation = false

  route {
      name = "route1"
      address_prefix = "0.0.0.0/0"
      next_hop_type = "Internet"
  }

  depends_on = [
      "azurerm_resource_group.rg"
  ]
}

resource "azurerm_subnet_route_table_association" "rtassc1" {
  subnet_id = "${azurerm_subnet.subnet2.id}"
  route_table_id = "${azurerm_route_table.rt1.id}"

  depends_on = [
      "azurerm_route_table.rt1"
  ]

}

resource "azurerm_public_ip" "eip" {
  name = "PublicIP"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method = "Static"
}


resource "azurerm_network_interface" "nic1" {
  name = "subnet1-nic"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
      name = "config1"
      subnet_id = "${azurerm_subnet.subnet1.id}"
      private_ip_address_allocation = "Dynamic"
  }

  depends_on = [
      "azurerm_subnet.subnet1"
  ]
}

resource "azurerm_network_interface" "nic2" {
  name = "subnet2-nic"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
      name = "config1"
      subnet_id = "${azurerm_subnet.subnet2.id}"
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = "${azurerm_public_ip.eip.id}"
  }

  depends_on = [
      "azurerm_subnet.subnet2"
  ]
}

resource "azurerm_network_security_group" "sg1" {
  name = "PrivSG"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
      name = "SSH"
      priority = 100
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = 22
      destination_port_range = 22
      source_address_prefix = "${var.subnet2_address_space}"
      destination_address_prefix = "${var.subnet1_address_space}"
  }

  depends_on = [
      "azurerm_resource_group.rg"
  ]
}

resource "azurerm_network_security_group" "sg2" {
  name = "PublicSG"
  location = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
      name = "SSH"
      priority = 100
      direction = "Inbound"
      access = "Allow"
      protocol = "Tcp"
      source_port_range = "*"
      destination_port_range = 22
      source_address_prefix = "Internet"
      destination_address_prefix = "*"
  }

  depends_on = [
      "azurerm_resource_group.rg"
  ]
}

resource "azurerm_subnet_network_security_group_association" "sgassoc1" {
  subnet_id = "${azurerm_subnet.subnet1.id}"
  network_security_group_id = "${azurerm_network_security_group.sg1.id}"

  depends_on = [
      "azurerm_subnet.subnet1",
      "azurerm_network_security_group.sg1"
  ]
}

resource "azurerm_subnet_network_security_group_association" "sgassoc2" {
  subnet_id = "${azurerm_subnet.subnet2.id}"
  network_security_group_id = "${azurerm_network_security_group.sg2.id}"
  
  depends_on = [
      "azurerm_subnet.subnet2",
      "azurerm_network_security_group.sg2"
  ]
}
