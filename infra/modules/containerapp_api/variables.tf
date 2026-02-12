variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "prefix" { type = string }

variable "environment_id" { type = string }

variable "acr_id" { type = string }
variable "acr_login_server" { type = string }

variable "app_image_name" { type = string }
variable "app_image_tag" { type = string }

variable "keyvault_id" { type = string }
variable "keyvault_secret_id" { type = string }

variable "identity_id" {
  type = string
}

variable "identity_principal_id" {
  type = string
}
