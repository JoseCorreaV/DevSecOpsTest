output "acr_id" {
  value = module.acr.acr_id
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "keyvault_id" {
  value = module.keyvault.key_vault_id
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
