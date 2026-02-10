resource "azurerm_container_app_environment" "this" {
  name                = "${var.prefix}-cae"
  location            = var.location
  resource_group_name = var.resource_group_name
}
