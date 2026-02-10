output "key_vault_id" {
  value = azurerm_key_vault.this.id
}


output "secret_id" {
  value = azurerm_key_vault_secret.my_secret.id
}
