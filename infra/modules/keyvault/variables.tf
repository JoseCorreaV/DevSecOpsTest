variable "prefix" {
  type        = string
  description = "Prefijo para naming. Ej: techflowdev"
}

variable "location" {
  type        = string
  description = "Azure region. Ej: eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group donde se crea el KeyVault."
}

variable "my_secret_value" {
  type        = string
  description = "Valor del secreto my-secret."
  sensitive   = true
}

variable "secrets_officer_principal_ids" {
  type        = list(string)
  description = "Azure AD Object IDs con rol 'Key Vault Secrets Officer' sobre el vault."
}
