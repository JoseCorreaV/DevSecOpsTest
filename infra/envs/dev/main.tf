terraform {
  backend "azurerm" {}

  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.100.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.12.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azapi" {}

module "acr" {
  source              = "../../modules/acr"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix
}

module "keyvault" {
  source                        = "../../modules/keyvault"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  prefix                        = var.prefix
  secrets_officer_principal_ids = var.keyvault_secrets_officer_principal_ids
  my_secret_value               = var.my_secret_value
}

module "cae" {
  source              = "../../modules/containerapps_env"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix
}

module "identity" {
  source              = "../../modules/identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix
}

module "api" {
  source              = "../../modules/containerapp_api"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix

  environment_id = module.cae.environment_id

  acr_id           = module.acr.acr_id
  acr_login_server = module.acr.login_server

  app_image_name = "techflow-api"
  app_image_tag  = var.app_image_tag

  keyvault_id        = module.keyvault.key_vault_id
  keyvault_secret_id = module.keyvault.secret_id

  identity_id           = module.identity.id
  identity_principal_id = module.identity.principal_id
}

module "job" {
  source              = "../../modules/containerapp_job"
  resource_group_name = var.resource_group_name
  location            = var.location
  prefix              = var.prefix

  environment_id = module.cae.environment_id

  acr_id           = module.acr.acr_id
  acr_login_server = module.acr.login_server

  job_image_name = "techflow-job"
  job_image_tag  = var.job_image_tag

  keyvault_id        = module.keyvault.key_vault_id
  keyvault_secret_id = module.keyvault.secret_id

  trigger_type = "Manual"
  # trigger_type    = "Schedule"
  # cron_expression = "*/10 * * * *"

  identity_id           = module.identity.id
  identity_principal_id = module.identity.principal_id
}
