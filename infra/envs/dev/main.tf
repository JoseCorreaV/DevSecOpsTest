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
  # Si lo quisieras en cron:
  # trigger_type = "Schedule"
  # cron_expression = "*/10 * * * *"

  identity_id           = module.identity.id
  identity_principal_id = module.identity.principal_id
}
