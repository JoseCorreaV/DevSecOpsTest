variable "resource_group_name" { type = string }
variable "location"            { type = string }
variable "prefix"              { type = string }

variable "my_secret_value" {
  type      = string
  sensitive = true
}
