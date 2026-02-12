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

# Normaliza el prefix para que Azure no reviente por nombres inválidos:
# - solo minúsculas
# - evita "--"
# - evita terminar en "-"
# - recorta longitud para dejar espacio a sufijos (-cae/-api/-job/-kv/-acr)
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

  # recorta longitud
  cut = substr(local.c4, 0, 24)

  # si termina en "-", agrega "x" para terminar en alfanumérico
  last_char  = substr(local.cut, length(local.cut) - 1, 1)
  prefix_fix = local.last_char == "-" ? "${local.cut}x" : local.cut

  prefix = local.prefix_fix
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

  # si tu módulo lo soporta (si no, bórralos)
  trigger_type    = var.trigger_type
  cron_expression = var.cron_expression
}
