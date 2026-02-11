variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "prefix"              { type = string }

variable "secrets_officer_principal_ids" {
  type        = list(string)
  description = "Azure AD object IDs con permisos para gestionar secretos en el Key Vault (RBAC)."
}

variable "my_secret_value" {
  type      = string
  sensitive = true
}
