variable "prefix" {
  type        = string
  description = "Prefijo de recursos (ej: techflowdev-)."
}

variable "location" {
  type        = string
  description = "Región de Azure."
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group donde se crean recursos."
}

variable "my_secret_value" {
  type        = string
  description = "Valor del secreto 'my-secret' que se guardará en KeyVault."
  sensitive   = true
}
