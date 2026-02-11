variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "prefix"              { type = string }

variable "secrets_officer_principal_ids" {
  type        = list(string)
  description = "Azure AD object IDs con permisos 'Key Vault Secrets Officer' sobre el vault."
}

variable "my_secret_value" {
  type      = string
  sensitive = true
}
