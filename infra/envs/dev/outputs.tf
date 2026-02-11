output "acr_id" {
  value = module.acr.acr_id
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "keyvault_id" {
  value = module.keyvault.key_vault_id
}

output "keyvault_name" {
  value = module.keyvault.key_vault_name
}

output "vault_uri" {
  value = module.keyvault.vault_uri
}

output "containerapp_name" {
  value = "${var.prefix}-api"
}

output "job_name" {
  value = "${var.prefix}-job"
}

output "uami_id" {
  value = module.identity.id
}

output "uami_principal_id" {
  value = module.identity.principal_id
}

output "cae_environment_id" {
  value = module.cae.environment_id
}
