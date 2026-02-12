data "azurerm_client_config" "current" {}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = var.identity_principal_id

  name = uuidv5(
    "6ba7b811-9dad-11d1-80b4-00c04fd430c8",
    "${var.acr_id}|AcrPull|${var.identity_principal_id}"
  )
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

resource "azapi_resource" "api" {
  type      = "Microsoft.App/containerApps@2023-05-01"
  name      = "${var.prefix}api"
  location  = var.location
  parent_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.resource_group_name}"

  ignore_missing_property   = true
  schema_validation_enabled = false

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  body = {
    properties = {
      managedEnvironmentId = var.environment_id

      configuration = {
        ingress = {
          external   = true
          targetPort = 8080
          traffic = [
            { latestRevision = true, weight = 100 }
          ]
        }

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
      }

      template = {
        # INIT CONTAINER (cumple el requisito del doc)
        initContainers = [
          {
            name    = "init"
            image   = "alpine:3.20"
            command = ["/bin/sh"]
            args    = ["-lc", "echo 'Iniciando...' && sleep 5"]
            resources = {
              cpu    = 0.1
              memory = "0.1Gi"
            }
          }
        ]

        containers = [
          {
            name  = "api"
            image = "${var.acr_login_server}/${var.app_image_name}:${var.app_image_tag}"

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
