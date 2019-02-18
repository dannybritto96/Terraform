provider "azurerm" {
    subscription_id = "" #use this block if you have more than one subscription
}

data "azurerm_resource_group" "app_gateway_rg" {
    name = "${var.app-gateway-resource-group}"
}


data "azurerm_resource_group" "existing_vnet_resource_group" {
    name = "${var.vnet-rg}"
}

data "azurerm_virtual_network" "existing_vnet_name" {
    name = "${var.existing-vnet}"
    resource_group_name = "${var.resource_group_name}"
}

data "azurerm_subnet" "existing_subnet" {
    name = "${var.existing-subnet}"
    virtual_network_name = "${data.azurerm_virtual_network.existing_vnet_name.name}"
    resource_group_name = "${data.azurerm_resource_group.existing_vnet_resource_group.name}"
}


resource "azurerm_virtual_machine_scale_set" "SampVMSS" {
    name = "${var.vmss_name}"
    location = "${var.location}"
    resource_group_name = "${var.resource_group_name}"
    automatic_os_upgrade = false
    upgrade_policy_mode = "Manual"
    sku {
        name = "${var.vm_sku}"
        tier = "Standard"
        capacity = "${var.instance_count}"
    }

    os_profile{
        computer_name_prefix = "vmss"
        admin_username = "${var.admin_username}"
        admin_password = "${var.admin_password}"
    }

    os_profile_windows_config {
        enable_automatic_upgrades = false
    }

    storage_profile_os_disk {
        name = ""
        caching = "ReadWrite"
        create_option = "FromImage"
        managed_disk_type = "Standard_LRS"
    }

    storage_profile_image_reference {
        publisher = "${var.image_publisher}"
        offer = "${var.image_offer}"
        sku = "${var.windowsOSVersion}"
        version = "${var.image_version}"
    }

    network_profile {
        name = "nic"
        primary = true

        ip_configuration {
            name = "ipconfig"
            subnet_id = "${data.azurerm_subnet.existing_subnet.id}"
            primary = true
            application_gateway_backend_address_pool_ids = ["${data.azurerm_resource_group.app_gateway_rg.id}/providers/Microsoft.Network/applicationGateways/${var.app-gateway}/backendAddressPools/${var.existing-app-gateway-backend-pool}"]
            } 
        }
    
    extension {
        name = "Microsoft.Powershell.DSC"
        publisher = "Microsoft.Powershell"
        type = "DSC"
        type_handler_version = "2.9"
        settings = <<SETTINGS

        {
            "configuration": {
                "url": "${var.powershellDSCzip}",
                "script": "IISInstall.ps1",
                "function": "InstallIIS"
            },
            "configurationArguments": {
                "nodeName": "localhost",
                "WebDeployPackagePath": "${var.WebDeployPackage}"
            }
        }

        SETTINGS
    }
}

resource "azurerm_autoscale_setting" "autoscale1" {
    
    name                = "myAutoscaleSetting"
    resource_group_name = "${var.resource_group_name}"
    location            = "${var.location}"
    target_resource_id  = "${azurerm_virtual_machine_scale_set.SampVMSS.id}"

    profile {
        name = "defaultProfile"
        capacity {
        default = 1
        minimum = 1
        maximum = "${var.instance_count}"
        }

        rule {
        metric_trigger {
            metric_name        = "Percentage CPU"
            metric_resource_id = "${azurerm_virtual_machine_scale_set.SampVMSS.id}"
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "GreaterThan"
            threshold          = 75
        }

        scale_action {
            direction = "Increase"
            type      = "ChangeCount"
            value     = "1"
            cooldown  = "PT1M"
        }
        }

        rule {
        metric_trigger {
            metric_name        = "Percentage CPU"
            metric_resource_id = "${azurerm_virtual_machine_scale_set.SampVMSS.id}"
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "LessThan"
            threshold          = 25
        }

        scale_action {
            direction = "Decrease"
            type      = "ChangeCount"
            value     = "1"
            cooldown  = "PT1M"
        }
        }
    }

    notification {
        email {
        send_to_subscription_administrator    = true
        send_to_subscription_co_administrator = true
        }
    }

}