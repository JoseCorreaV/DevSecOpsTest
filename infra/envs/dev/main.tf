terraform {
  required_version = ">= 1.5.0"

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
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
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "cae" {
  source              = "../../modules/containerapp_env"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "identity" {
  source              = "../../modules/identity"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "keyvault" {
  source              = "../../modules/keyvault"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  # Se setea desde GitHub Actions (TF_VAR_my_secret_value)
  my_secret_value     = var.my_secret_value
}

module "api" {
  source              = "../../modules/containerapp_api"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  environment_id     = module.cae.environment_id
  acr_id             = module.acr.acr_id
  acr_login_server   = module.acr.login_server

  identity_id           = module.identity.id
  identity_principal_id = module.identity.principal_id

  keyvault_id        = module.keyvault.key_vault_id
  keyvault_secret_id = module.keyvault.secret_versionless_id

  app_image_name = var.app_image_name
  app_image_tag  = var.app_image_tag
}

module "job" {
  source              = "../../modules/containerapp_job"
  prefix              = var.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  environment_id     = module.cae.environment_id
  acr_id             = module.acr.acr_id
  acr_login_server   = module.acr.login_server

  identity_id           = module.identity.id
  identity_principal_id = module.identity.principal_id

  keyvault_id        = module.keyvault.key_vault_id
  keyvault_secret_id = module.keyvault.secret_versionless_id

  job_image_name = var.job_image_name
  job_image_tag  = var.job_image_tag
}
