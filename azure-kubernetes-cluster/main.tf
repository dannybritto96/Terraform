provider "azurerm" {
    subscription_id = ""
}

data "azurerm_resource_group" "aks_rg" {
    name = "${var.resource_group_name}"
}

data "azurerm_subnet" "aks_subnet" {
    name = "${var.subnet_name}"
    virtual_network_name = "${var.VNET_name}"
    resource_group_name = "${var.VNET_RG}"
}

data "azurerm_log_analytics_workspace" "log_workspace" {
    name = "${var.managedClusters_logAnalyticsWorkspaceResourceName}"
    resource_group_name = "${var.managedClusters_logAnalyticsWorkspaceResource_RG}"
}

resource "azurerm_container_registy" "aks_registry" {
  name = "${var.registries_name}"
  resource_group_name = "${data.azurerm_resource_group.aks_rg.name}"
  location = "${var.location}"
  admin_enabled = false
  sku = "Basic"
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name = "${var.managedClusters_name}"
  location = "${var.location}"
  kubernetes_version = "1.12.5"
  dns_prefix = "mycases-dev"

  role_based_access_control {
          enabled = "True"
  }

  agent_pool_profile {
      name = "agentpool"
      count = 3
      vm_size = "Standard_B2s"
      os_type = "Linux"
      os_disk_size_gb = 30
      max_pods = 110
      vnet_subnet_id = "${data.azurerm_subnet.aks_subnet.id}"
  }

  service_principal{
      client_id = ""
      client_secret = ""
  }

  addon_profile {
      http_application_routing {
          enabled = true
      }

      oms_agent {
          enabled = true
          log_analytics_workspace_id = "${data.azurerm_log_analytics_workspace.log_workspace.id}"
      }
  }

}
