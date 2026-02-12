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
  # 1) lowercase
  raw_prefix = lower(var.prefix)

  # 2) reemplaza separadores típicos por '-'
  s1 = replace(local.raw_prefix, "_", "-")
  s2 = replace(local.s1, " ", "-")
  s3 = replace(local.s2, ".", "-")
  s4 = replace(local.s3, "/", "-")
  s5 = replace(local.s4, "\\", "-")
  s6 = replace(local.s5, ":", "-")
  s7 = replace(local.s6, "@", "-")

  # 3) colapsa múltiples '--'
  c1 = replace(local.s7, "--", "-")
  c2 = replace(local.c1, "--", "-")
  c3 = replace(local.c2, "--", "-")
  c4 = replace(local.c3, "--", "-")
  c5 = replace(local.c4, "--", "-")

  # 4) reserva espacio para "-api" (4 chars)
  base_cut = substr(local.c5, 0, 28)

  # 5) garantiza que NO termine en '-' (si termina en '-', agrega 'x')
  #    (sin regex: revisamos el último caracter con substr)
  last_char = substr(local.base_cut, length(local.base_cut) - 1, 1)
  base_ok   = local.last_char == "-" ? "${local.base_cut}x" : local.base_cut

  # 6) garantiza que empiece con letra (si no, antepone 'a')
  first_char = substr(local.base_ok, 0, 1)
  prefix_ok  = contains(["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"], local.first_char) ? local.base_ok : "a-${local.base_ok}"

  # 7) nombre final
  app_name = "${local.prefix_ok}-api"

  # 8) última colapsada por si el "a-" generó doble guion
  app_name_final_1 = replace(local.app_name, "--", "-")
  app_name_final_2 = replace(local.app_name_final_1, "--", "-")
  app_name_final_3 = replace(local.app_name_final_2, "--", "-")
  app_name_final   = local.app_name_final_3
}

resource "azurerm_container_app" "this" {
  name                         = local.app_name_final
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

      env {
        name        = "MY_SECRET"
        secret_name = "my-secret"
      }
    }
  }
}
