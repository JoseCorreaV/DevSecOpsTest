output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "key_vault_name" {
  value = azurerm_key_vault.this.name
}

# URL versionless del secreto (útil para Container Apps / Jobs con KeyVaultUrl)
output "secret_versionless_id" {
  value = "${azurerm_key_vault.this.vault_uri}secrets/${azurerm_key_vault_secret.my_secret.name}"
}
