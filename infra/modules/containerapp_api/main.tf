data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.acr_id}|AcrPull|api|${var.identity_principal_id}"
  )
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.keyvault_id}|Key Vault Secrets User|api|${var.identity_principal_id}"
  )
}

locals {
  raw_prefix = lower(var.prefix)

  # Reemplaza cualquier cosa rara por '-' y evita '--'
  cleaned_prefix = regexreplace(local.raw_prefix, "[^a-z0-9-]", "-")
  no_double_dash = regexreplace(local.cleaned_prefix, "-{2,}", "-")

  # Debe iniciar con letra; si no, antepone 'a'
  starts_ok = can(regex("^([a-z]).*$", local.no_double_dash)) ? local.no_double_dash : "a-${local.no_double_dash}"

  # Quita '-' al final si quedó
  trimmed = regexreplace(local.starts_ok, "-+$", "")

  # Reserva espacio para "-api" (4 chars)
  safe_prefix = substr(local.trimmed, 0, 28)
  app_name    = "${local.safe_prefix}-api"
}

resource "azurerm_container_app" "this" {
  name                         = local.app_name
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

  # Secreto proveniente de Key Vault (NO valor plano en TF)
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
      name  = "init"
      image = "alpine:3.20"
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

      # Inyecta el secreto como env var segura
      env {
        name        = "MY_SECRET"
        secret_name = "my-secret"
      }
    }
  }
}
