variable "resource_group_name" {
  type        = string
  description = "Nombre del Resource Group existente o a usar"
}

variable "location" {
  type        = string
  description = "Azure region (ej: eastus)"
}

variable "prefix" {
  type        = string
  description = "Prefijo para nombres de recursos (ej: techflowdev)"
}

variable "my_secret_value" {
  type        = string
  sensitive   = true
  description = "Valor del secreto que se guardará en Key Vault (NO en código)"
}

variable "app_image_tag" {
  type        = string
  description = "Tag de la imagen techflow-api en ACR (ej: 1.0.0)"
  default     = "1.0.0"
}

variable "job_image_tag" {
  type        = string
  description = "Tag de la imagen techflow-job en ACR (ej: 1.0.0)"
  default     = "1.0.0"
}
