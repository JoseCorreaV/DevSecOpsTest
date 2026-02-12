variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }

variable "environment_id" { type = string }

variable "acr_id" { type = string }
variable "acr_login_server" { type = string }

variable "job_image_name" { type = string }
variable "job_image_tag" { type = string }

variable "trigger_type" {
  type    = string
  default = "Manual"
}

variable "cron_expression" {
  type    = string
  default = "*/10 * * * *"
}

variable "identity_id" {
  type = string
}

variable "identity_principal_id" {
  type = string
}


variable "keyvault_id" {
  type        = string
  description = "Resource ID del Key Vault"
}

variable "keyvault_secret_id" {
  type        = string
  description = "ID/URL del secreto en Key Vault (secret id)"
}
