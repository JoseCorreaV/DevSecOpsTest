data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.acr_id}|AcrPull|${var.identity_principal_id}"
  )

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.keyvault_id}|Key Vault Secrets User|${var.identity_principal_id}"
  )

  skip_service_principal_aad_check = true
}

resource "azapi_resource" "job" {
  type      = "Microsoft.App/jobs@2023-05-01"
  name      = "${var.prefix}-job"
  location  = var.location
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  schema_validation_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  body = {
    properties = {
      environmentId = var.environment_id

      configuration = {
        triggerType       = var.trigger_type
        replicaRetryLimit = 0
        replicaTimeout    = 300

        registries = [
          {
            server   = var.acr_login_server
            identity = var.identity_id
          }
        ]

        secrets = [
          {
            name        = "my-secret"
            keyVaultUrl = var.keyvault_secret_id
            identity    = var.identity_id
          }
        ]

        scheduleTriggerConfig = var.trigger_type == "Schedule" ? {
          cronExpression = var.cron_expression
        } : null
      }

      template = {
        containers = [
          {
            name  = "job"
            image = "${var.acr_login_server}/${var.job_image_name}:${var.job_image_tag}"

            env = [
              {
                name      = "MY_SECRET"
                secretRef = "my-secret"
              }
            ]

            resources = {
              cpu    = 0.25
              memory = "0.5Gi"
            }
          }
        ]
      }
    }
  }

  depends_on = [
    azurerm_role_assignment.acr_pull,
    azurerm_role_assignment.kv_secrets_user
  ]
}
