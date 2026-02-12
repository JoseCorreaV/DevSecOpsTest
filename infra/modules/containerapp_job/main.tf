data "azurerm_client_config" "current" {}

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

locals {
  raw_prefix = lower(var.prefix)

  no_double_dash_1 = replace(local.raw_prefix, "--", "-")
  no_double_dash_2 = replace(local.no_double_dash_1, "--", "-")
  no_double_dash_3 = replace(local.no_double_dash_2, "--", "-")
  no_double_dash_4 = replace(local.no_double_dash_3, "--", "-")

  safe_prefix = substr(local.no_double_dash_4, 0, 28)

  job_name = "${local.safe_prefix}-job"
}


resource "azurerm_container_app_job" "this" {
  name                         = local.job_name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  container_app_environment_id = var.environment_id
  replica_timeout_in_seconds   = 1800
  replica_retry_limit          = 1


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

  dynamic "manual_trigger_config" {
    for_each = lower(var.trigger_type) == "manual" ? [1] : []
    content {
      parallelism              = 1
      replica_completion_count = 1
    }
  }

  dynamic "schedule_trigger_config" {
    for_each = lower(var.trigger_type) == "schedule" ? [1] : []
    content {
      cron_expression          = var.cron_expression
      parallelism              = 1
      replica_completion_count = 1
    }
  }
  
  template {
    container {
      name   = "job"
      image  = "${var.acr_login_server}/${var.job_image_name}:${var.job_image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      env {
        name        = "MY_SECRET"
        secret_name = "my-secret"
      }
    }
  }
}
