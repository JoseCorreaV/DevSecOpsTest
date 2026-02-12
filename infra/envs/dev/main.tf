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


locals {
  raw_prefix = lower(var.prefix)

  # reemplaza separadores comunes por "-"
  s1 = replace(local.raw_prefix, "_", "-")
  s2 = replace(local.s1, " ", "-")
  s3 = replace(local.s2, ".", "-")
  s4 = replace(local.s3, "/", "-")
  s5 = replace(local.s4, "\\", "-")
  s6 = replace(local.s5, ":", "-")
  s7 = replace(local.s6, "@", "-")

  # colapsa múltiples "--"
  c1 = replace(local.s7, "--", "-")
  c2 = replace(local.c1, "--", "-")
  c3 = replace(local.c2, "--", "-")
  c4 = replace(local.c3, "--", "-")

  # si termina en "-", QUÍTALO (no agregues nada)
  last_char = substr(local.c4, length(local.c4) - 1, 1)
  trimmed   = local.last_char == "-" ? substr(local.c4, 0, length(local.c4) - 1) : local.c4

  # recorta longitud por safety
  prefix = substr(local.trimmed, 0, 24)
}


module "acr" {
  source              = "../../modules/acr"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "cae" {
  source              = "../../modules/containerapps_env"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "identity" {
  source              = "../../modules/identity"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

module "keyvault" {
  source              = "../../modules/keyvault"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  my_secret_value = var.my_secret_value
}

module "api" {
  source              = "../../modules/containerapp_api"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  environment_id   = module.cae.environment_id
  acr_id           = module.acr.acr_id
  acr_login_server = module.acr.login_server

  identity_id           = module.identity.id
  identity_principal_id = module.identity.principal_id

  keyvault_id        = module.keyvault.key_vault_id
  keyvault_secret_id = module.keyvault.secret_versionless_id

  app_image_name = var.app_image_name
  app_image_tag  = var.app_image_tag
}

module "job" {
  source              = "../../modules/containerapp_job"
  prefix              = local.prefix
  location            = var.location
  resource_group_name = var.resource_group_name

  environment_id   = module.cae.environment_id
  acr_id           = module.acr.acr_id
  acr_login_server = module.acr.login_server

  identity_id           = module.identity.id
  identity_principal_id = module.identity.principal_id

  keyvault_id        = module.keyvault.key_vault_id
  keyvault_secret_id = module.keyvault.secret_versionless_id

  job_image_name = var.job_image_name
  job_image_tag  = var.job_image_tag
}
