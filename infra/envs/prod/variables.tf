variable "prefix" {
  description = "Prefijo base para nombres (prod). Evita terminar en '-' idealmente."
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "Resource Group destino (prod)"
  type        = string
}

variable "app_image_name" {
  description = "Nombre del repo/imagen para API en ACR"
  type        = string
  default     = "techflow-api"
}

variable "app_image_tag" {
  description = "Tag/sha de imagen API (prod)"
  type        = string
}

variable "job_image_name" {
  description = "Nombre del repo/imagen para JOB en ACR"
  type        = string
  default     = "techflow-job"
}

variable "job_image_tag" {
  description = "Tag/sha de imagen JOB (prod)"
  type        = string
}

variable "my_secret_value" {
  description = "Valor del secreto a guardar en KeyVault (prod). NO lo commitees en tfvars real."
  type        = string
  sensitive   = true
}

# Opcionales (si tu módulo job lo soporta)
variable "trigger_type" {
  description = "manual | schedule"
  type        = string
  default     = "manual"
}

variable "cron_expression" {
  description = "Cron (solo si trigger_type=schedule). Ej: */5 * * * *"
  type        = string
  default     = ""
}
