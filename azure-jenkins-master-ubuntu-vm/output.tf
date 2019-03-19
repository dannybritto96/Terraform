output "jenkinsURL" {
  value = "http://${azurerm_public_ip.public_ip.fqdn}"
}

output "ssh" {
  value = "ssh -L 8080:localhost:8080 ${var.adminUsername}@${azurerm_public_ip.public_ip.fqdn}"
}
