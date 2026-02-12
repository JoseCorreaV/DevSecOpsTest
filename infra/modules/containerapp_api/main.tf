data "azurerm_client_config" "current" {}

# Solo dejamos KV role aquí (AcrPull se gestiona en el módulo JOB para evitar 409)
resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.keyvault_id}|Key Vault Secrets User|api|${var.identity_principal_id}"
  )
}

resource "azurerm_container_app" "this" {
  name                         = "${var.prefix}-api"
  container_app_environment_id = var.environment_id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  registry {
    server   = var.acr_login_server
    identity = var.identity_id
  }

  # Secreto desde KeyVault referenciado por ID (no valor plano en TF)
  secret {
    name                = "my-secret"
    identity            = var.identity_id
    key_vault_secret_id = var.keyvault_secret_id
  }

  ingress {
    external_enabled = true
    target_port      = 3000

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 1
    max_replicas = 1

    init_container {
      name   = "init"
      image  = "alpine:3.20"
      cpu    = 0.25
      memory = "0.5Gi"

      command = [
        "sh",
        "-lc",
        "echo \"Iniciando...\" && sleep 5"
      ]
    }

    container {
      name   = "api"
      image  = "${var.acr_login_server}/${var.app_image_name}:${var.app_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "MY_SECRET"
        secret_name = "my-secret"
      }
    }
  }
}
