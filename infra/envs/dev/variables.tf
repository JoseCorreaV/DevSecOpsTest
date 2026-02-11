variable "prefix" {
  type        = string
  description = "Prefijo de recursos."
  default     = "techflowdev-"
}

variable "location" {
  type        = string
  description = "Región de Azure."
  default     = "eastus"
}

variable "resource_group_name" {
  type        = string
  description = "Resource Group destino."
  default     = "rg-techflow-dev"
}

# Valores usados por los módulos de container apps / jobs
variable "app_image_name" {
  type        = string
  description = "Nombre base de la imagen API."
  default     = "techflow-api"
}

variable "job_image_name" {
  type        = string
  description = "Nombre base de la imagen Job."
  default     = "techflow-job"
}

# Tags (se setean desde GitHub Actions en apply; en PR no son necesarios)
variable "app_image_tag" {
  type        = string
  description = "Tag de imagen para la API."
  default     = "1.0.0"
}

variable "job_image_tag" {
  type        = string
  description = "Tag de imagen para el Job."
  default     = "1.0.0"
}

# Secreto del KeyVault (se inyecta por TF_VAR_my_secret_value)
variable "my_secret_value" {
  type        = string
  description = "Valor del secreto 'my-secret'."
  sensitive   = true
}
