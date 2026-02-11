data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = "${var.prefix}kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled = true

  # Checkov: recoverable + purge protection
  purge_protection_enabled   = true
  soft_delete_retention_days = 7

  # En laboratorio lo dejas abierto; para pasar Checkov completo necesitarías Private Endpoint + firewall rules
  public_network_access_enabled = true
}

# Permite que quien ejecuta Terraform (tu usuario) cree/lea secretos.
resource "azurerm_role_assignment" "secrets_officer_current" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "my_secret" {
  name         = "my-secret"
  value        = var.my_secret_value
  key_vault_id = azurerm_key_vault.this.id

  # Checkov: content_type + expiration
  content_type    = "text/plain"
  expiration_date = timeadd(timestamp(), "8760h") # +1 año

  depends_on = [azurerm_role_assignment.secrets_officer_current]
}
