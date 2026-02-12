output "name" {
  value = azurerm_container_app.this.name
}

output "id" {
  value = azurerm_container_app.this.id
}

output "fqdn" {
  value = try(azurerm_container_app.this.ingress[0].fqdn, null)
}
