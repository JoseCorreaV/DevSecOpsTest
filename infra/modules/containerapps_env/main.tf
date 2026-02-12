resource "azurerm_container_app_environment" "this" {
  name                = "${var.prefix}-cae"
  location            = var.location
  resource_group_name = var.resource_group_name

  lifecycle {
    # Evita que Terraform intente destruir el CAE.
    # Azure devuelve 409 si aún existen Container Apps dentro del Environment.
    prevent_destroy = true
  }
}
