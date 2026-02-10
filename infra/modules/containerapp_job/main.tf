data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.identity_principal_id
}

resource "azapi_resource" "job" {
  type      = "Microsoft.App/jobs@2023-05-01"
  name      = "${var.prefix}-job"
  location  = var.location
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  # Jobs a veces cambian schema: mejor sin validación estricta
  schema_validation_enabled = false

  # ✅ AZAPI identity (NO user_assigned_identities)
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

        scheduleTriggerConfig = var.trigger_type == "Schedule" ? {
          cronExpression = var.cron_expression
        } : null
      }

      template = {
        containers = [
          {
            name  = "job"
            image = "${var.acr_login_server}/${var.job_image_name}:${var.job_image_tag}"
            resources = {
              cpu    = 0.25
              memory = "0.5Gi"
            }
          }
        ]
      }
    }
  }

  depends_on = [azurerm_role_assignment.acr_pull]
}
