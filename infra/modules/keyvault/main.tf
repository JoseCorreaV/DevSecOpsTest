data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = "${var.prefix}kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  # RBAC mode (recomendado)
  rbac_authorization_enabled = true

  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = true
}

# Nota:
# - Los roles RBAC (p.ej. 'Key Vault Secrets Officer') para el Service Principal del pipeline
#   se asignan fuera de Terraform (bootstrap) para evitar 403 durante plan/apply por propagación.
# - El secreto se gestiona en Terraform (abajo) y el valor llega por variable TF_VAR_my_secret_value.
resource "azurerm_key_vault_secret" "my_secret" {
  name         = "my-secret"
  value        = var.my_secret_value
  key_vault_id = azurerm_key_vault.this.id

  content_type    = "text/plain"
  expiration_date = timeadd(timestamp(), "8760h")
}
