output "acr_id" {
  value = module.acr.acr_id
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "cae_environment_id" {
  value = module.cae.environment_id
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

output "secret_versionless_id" {
  value = module.keyvault.secret_versionless_id
}

output "uami_id" {
  value = module.identity.id
}

output "uami_principal_id" {
  value = module.identity.principal_id
}
