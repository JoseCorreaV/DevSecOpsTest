data "azurerm_client_config" "current" {}

# Roles para que la UAMI pueda:
# - PULL en ACR
# - Leer secretos en KeyVault
resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.acr_id}|AcrPull|job|${var.identity_principal_id}"
  )
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.keyvault_id}|Key Vault Secrets User|job|${var.identity_principal_id}"
  )
}

resource "azurerm_container_app_job" "this" {
  name                         = "${var.prefix}-job"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.cae_environment_id

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  trigger_type = "Manual"

  template {
    container {
      name   = "job"
      image  = "${var.acr_login_server}/${var.job_image_name}:${var.job_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"
    }
  }
}
