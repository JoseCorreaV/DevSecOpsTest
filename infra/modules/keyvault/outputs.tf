output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

output "keyvault_name" {
  value = azurerm_key_vault.this.name
}

output "secret_id" {
  # versionless_id sirve para KeyVaultUrl en Container Apps/Jobs
  value = azurerm_key_vault_secret.my_secret.versionless_id
}
