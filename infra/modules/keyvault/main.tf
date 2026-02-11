data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = "${var.prefix}kv"
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"

  rbac_authorization_enabled     = true
  purge_protection_enabled       = true
  soft_delete_retention_days     = 7
  public_network_access_enabled  = true
}

# ✅ Roles estables (no dependen de quién corre terraform)
resource "azurerm_role_assignment" "secrets_officer" {
  for_each             = toset(var.secrets_officer_principal_ids)
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = each.value

  # GUID estable (evita 409)
  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${azurerm_key_vault.this.id}|Key Vault Secrets Officer|${each.value}"
  )

  skip_service_principal_aad_check = true
}

# ✅ Espera a propagación RBAC (evita 403 en apply)
resource "time_sleep" "wait_for_rbac" {
  depends_on      = [azurerm_role_assignment.secrets_officer]
  create_duration = "60s"
}

resource "azurerm_key_vault_secret" "my_secret" {
  name         = "my-secret"
  value        = var.my_secret_value
  key_vault_id = azurerm_key_vault.this.id

  content_type    = "text/plain"
  expiration_date = timeadd(timestamp(), "8760h")

  depends_on = [time_sleep.wait_for_rbac]
}
